###
	tweak.component.js 0.8.5

	(c) 2014 Blake Newman.
	TweakJS may be freely distributed under the MIT license.
	For all details and documentation:
	http://tweakjs.com
###

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

###
class tweak.Component

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
  uid: 0

  require: tweak.Common.require
  clone: tweak.Common.clone
  combine: tweak.Common.combine
  findModule: tweak.Common.findModule

  ###
    @param [Object] relation Relation to the component
    @param [Object] options Configuartion for the component
  ###
  constructor: (relation, options) ->
    if not options? then throw new Error "No options given"

    # Set uid
    @uid = "c_#{tweak.uids.c++}"
    # Build relation if window and build its default properties
    # The relation is it direct caller
    relation = @relation = if relation is window then {} else relation
    relation.relation ?= {}
    # Get parent component
    @parent = if relation instanceof tweak.Components then relation.relation else relation
    @root = @parent.root or @
    # Set name of component
    @name = options.name
    if not @name? then throw new Error "No name given"

    @config = @buildConfig(options) or {}
    # The config file can prevent automatic build and start of componets
    # Start the construcion of the component
    @construct()

  ###
    @param [Object] options Component options
    @return [Object] returns combined config based on the configs extending inheritance
    Builds the config component
    It inteligently iherits modules, and configuration settings from its extending components
  ###
  buildConfig: (options) ->
    configs = []
    paths = @paths = []

    extension = @name
    if options
      paths.push @name
      configs.push @clone options
      if options.extends then extension = options.extends

    # Gets all configs, by configs extension path
    while extension
      requested = @require "#{extension}/config", @name
      # Store all the paths
      paths.push extension
      # Push a clone of the config file to remove reference
      configs.push @clone requested
      extension = requested.extends

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
    Add a module to the component, if module can't be found then it will use a surrogate object
    @param [String] name Name of the module
    @param [Object] surrogate Surrogate if the module can not be found
    @param [...] params Parameters passed into the module on constuction
    @return [Object] Constructed object
  ###
  addModule: (name, surrogate, params...) ->
    Module = @findModule @paths, name, @name, surrogate
    module = @[name] = new Module params...
    module.component = module.relation = @
    module.cuid = @uid
    module.root = @root
    module.config = @config[name]
    module

  ###
    Shortcut method to adding view using the addModule method
    @param [...] params Parameters passed to into the view constructor
    @return [Object] View
  ###
  addView: (params...) -> @addModule "view", tweak.View, params...

  ###
    Shortcut method to adding Model using the addModule method
    @param [...] params Parameters passed to into the model constructor
    @return [Object] Model
  ###
  addModel: (params...) -> @addModule "model", tweak.Model, params...

  ###
    Shortcut method to adding controller using the addModule method
    @param [...] params Parameters passed to into the controller constructor
    @return [Object] Controller
  ###
  addController: (params...) -> @addModule "controller", tweak.Controller, params...

  ###
    Shortcut method to adding components using the addModule method
    @param [...] params Parameters passed to into the components constructor
    @return [Object] Components
  ###
  addComponents: (params...) -> @addModule "components", tweak.Components, params...

  ###
    Shortcut method to adding router using the addModule method
    @param [...] params Parameters passed to into the router constructor
    @return [Object] Router
  ###
  addRouter: (params...) -> @addModule "router", tweak.Router, params...

  ###
    Function to call other function so the component can be impeded before starting
  ###
  construct: -> @init()

  ###
    Constructs the component and its modules using the addModule method
  ###
  init: ->
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

    for name in MODULES
      if name isnt "view" then @[name]?.init?()

  ###
    @private
  ###
  _componentRender: (type) ->
    tweak.Events.on @, "#{@uid}:view:#{type}ed", =>
      tweak.Events.on @, "#{@uid}:components:ready", =>
        setTimeout(=>
        tweak.Events.trigger "#{@uid}:ready", @name
        ,0)
      @components[type]()  
    @view[type]()

  ###
    Renders itself and its subcomponents
    @event #{@name}:ready Triggers ready event when itself and its components are ready/rendered
  ###
  render: -> @_componentRender "render"

  ###
    Rerenders itself and its subcomponents
    @event #{@name}:ready Triggers ready event when itself and its components are ready/rerendered
  ###
  rerender: -> @_componentRender "rerender"

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