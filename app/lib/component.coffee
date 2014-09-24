###
  TweakJS has its own unique twist to the MVC concept.

  The future of MVC doesnt always lie in web apps; the architecture to TweakJS allows for intergration of components anywhere on a website
  For example you can plug "Web Components" into your static site; like sliders, accordians.
  The flexibity is endless; allowing MVC to be used from small web components to full scale one page web apps.

  TweakJS wraps its Models, Views, Templates, and Controllers into a component module.
  The component module acts inteligently to build up your application with simple config files.
  Each component its built through a config object; this allows for powerfull configuration with tonnes of flexibity.

  Each component can have sub components which are accessible in both directions; although it is recommended to keep functionality seperate
  it sometimes comes in handy to have access to other parts of the application.

  Each component can extend another component, which will then inheret the models, views, templates, and controllers directly from that component.
  If you however want to extend a component yet using a different Model you can simply overrite that model, or extend the functionality to the components model.

  The config objects are extremely handy for making components reusable, with easy accessable configuration settings.

  @include tweak.Common.Empty
  @include tweak.Common.Events
  @include tweak.Common.Collections
  @include tweak.Common.Arrays
  @include tweak.Common.Modules
  @include tweak.Common.Components
  @include tweak.Common.Events
###
class tweak.Component

  tweak.Extend @, [
    tweak.Common.Empty,
    tweak.Common.Events,
    tweak.Common.Modules,
    tweak.Common.Collections,
    tweak.Common.Arrays,
    tweak.Common.Modules,
    tweak.Common.Components
  ]

  # Private constants
  MODULES = ["model", "view", "controller", "components", "router"]
  
  # @property [Object]
  model: null
  # @property [Object]
  view: null
  # @property [Object]
  components: null
  # @property [Object]
  controller: null
  # @property [Object]
  router: null
  # @property [Interger] The uid of this object - for unique reference
  uid: tweak.uid++

  ###
    @param [Object] relation Relation to the component
    @param [string] name Name of the component
    @param [Object] config (optional) Configuartion for the component
  ###
  constructor: (relation, name, config) ->
    # Build relation if window and build its default properties
    # The relation is it direct caller
    relation = @relation = if relation is window then {} else relation
    relation.relation ?= {}
    # Get parent component
    @parent = if relation instanceof tweak.Components then relation.relation else relation
    @root = @parent.root or @
    # Set name of component
    @name = name or ""

    @config = @buildConfig(config) or {}

    # The config file can prevent automatic build and start of componets
    if not @config.preventStart
      # Start the construcion of the component
      @start()



  ###
    @param [Object] options Component options
    @return [Object] returns combined config based on the configs extending inheritance
    Builds the config component
    It inteligently iherits modules, and configuration settings from its extending components
  ###
  buildConfig: (options) ->
    configs = []
    paths = @paths = []

    config = @name
    if options
      configs.push options
      paths.push @name
      config = config.extends

    # Gets all configs, by configs extension path
    while config
      requested = @require "#{config}/config"
      # Store all the paths
      paths.push config
      # Push a clone of the config file to remove reference
      configs.push @clone(requested)
      config = requested.extends

    # Combine all the config files into one
    # The values of the config files from lower down the chain have piortiy
    result = configs[configs.length-1]
    for i in [configs.length-2..0]
      result = @combine(result, configs[i])

    # Set initial values in config if they do not exist
    result.model ?= {}
    result.view ?= {}
    result.controller ?= {}
    result.components ?= []
    result.events ?= {}
    result

  ###
    Initiates the construction and initialisation of the component.
  ###
  start: ->
    @construct()
    @init()

  ###
    Add a module to the component, if module can't be found then it will use a surrogate object
    @param [String] name Name of the module
    @param [Object] surrogate Surrogate if the module can not be found
    @param [...] params Parameters passed into the module on constuction
    @return [Object] Constructed object
  ###
  addModule: (name, surrogate, params...) ->
    Module = @findModule(@paths, name, surrogate)
    module = @[name] = new Module(params...)
    module.component = module.relation = @
    module.root = @root
    module.config = @config[name]
    module

  ###
    Shortcut method to adding view using the addModule method
    @param [...] params Parameters passed to into the view constructor
    @return [Object] View
  ###
  addView: (params...) -> @addModule("view", tweak.View, params...)

  ###
    Shortcut method to adding Model using the addModule method
    @param [...] params Parameters passed to into the model constructor
    @return [Object] Model
  ###
  addModel: (params...) -> @addModule("model", tweak.Model, params...)

  ###
    Shortcut method to adding controller using the addModule method
    @param [...] params Parameters passed to into the controller constructor
    @return [Object] Controller
  ###
  addController: (params...) -> @addModule("controller", tweak.Controller, params...)

  ###
    Shortcut method to adding components using the addModule method
    @param [...] params Parameters passed to into the components constructor
    @return [Object] Components
  ###
  addComponents: (params...) -> @addModule("components", tweak.Components, params...)

  ###
    Shortcut method to adding router using the addModule method
    @param [...] params Parameters passed to into the router constructor
    @return [Object] Router
  ###
  addRouter: (params...) -> @addModule("router", tweak.Router, params...)

  ###
    Constructs the component and its modules using the addModule method
  ###
  construct: ->
    # Router is optional as it is perfomance heavy
    # So it needs to be explicility defind in the config for the component that it should be used
    if @config.router then @addRouter()

    # Add modules to the component
    @addModel()
    @addView()
    @addComponents()
    @addController()

    # Add references to the the modules
    for name in MODULES
      prop = @[name]
      prop?.parent = @parent
      prop?.component = @
      prop?.name = @name
      for item in MODULES
        if name isnt item then prop?[item] = @[item]

    # Construct the modules after they have been added
    for name in MODULES then @[name]?.construct?()

  ###
    initialise the component and its modules exept the view
  ###
  init: ->
    for name in MODULES
      if name isnt "view" then @[name]?.init?()

  ###
    @private
  ###
  _componentRender: (type) ->
    @on("#{@name}:view:#{type}ed", =>
      @on("#{@name}:components:ready", =>
        @trigger("#{@name}:ready", @name)
      )
      @components[type]()
    )
    @view[type]()

  ###
    Renders itself and its subcomponents
    @event #{@name}:ready Triggers ready event when itself and its components are ready/rendered
  ###
  render: -> @_componentRender("render")

  ###
    Rerenders itself and its subcomponents
    @event #{@name}:ready Triggers ready event when itself and its components are ready/rerendered
  ###
  rerender: -> @_componentRender("rerender")

  ###
    Destroy this component. It will clear the view if it exists; and removes it from collection if it is part of one
    @param [Boolean] quiet Setting to trigger change events
  ###
  destroy: (quiet) ->
    @view.clear()
    components = @relation.components
    if components?
      i = 0 
      for item in components.data
        if item.uid is @uid
          components.remove i, quiet
          return
        i++