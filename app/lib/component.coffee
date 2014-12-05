###
  tweak.component.js 1.0.0

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###

###
  @private
  Overrides tweak.View to contain additional rendering functionality.
  With this override; components render in order.
###
class tweak.ViewComponent extends tweak.View
  # Not using own tweak.extends method as codo doesnt detect that this is an extending class

  ###
    @private
    Add extra functionality based on it now supports components
  ###
  __renderable = (ctx) ->
    comps = ctx.relation.parent?.components?.data or []
    for item in comps
      if item is ctx.relation then break
      previousComponent = item
    if previousComponent?.model?.data.rendering
      tweak.Events.on ctx, "#{previousComponent.uid}:model:changed:rendering", (rendering) ->
        if not rendering
          setTimeout(->
            tweak.Events.trigger "#{@uid}:renderable"
          ,0)
    else
      setTimeout(->
        tweak.Events.trigger "#{@uid}:renderable"
      ,0)
      
tweak.View = tweak.ViewComponent

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

  # @property [Method] see tweak.Common.require
  require: tweak.Common.require
  # @property [Method] see tweak.Common.clone
  clone: tweak.Common.clone
  # @property [Method] see tweak.Common.combine
  combine: tweak.Common.combine
  # @property [Method] see tweak.Common.findModule
  findModule: tweak.Common.findModule
  # @property [Method] see tweak.Common.relToAbs
  relToAbs: tweak.Common.relToAbs

  super: tweak.super

  modules: ["model", "view", "components", "router", "controller"]

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
    # Router is optional as it is perfomance heavy
    # So it needs to be explicility defind in the config for the component that it should be used
    if @config.router then @addRouter()

    # Add modules to the component
    @addModel()
    @addView()
    @addComponents()
    @addController()

    # Add references to the the modules
    for name in @modules when prop = @[name]
      prop.parent = @parent
      prop.component = @
      for name2 in @modules when name isnt name2 and prop2 = @[name2]
        prop[name2] = prop2
      prop.construct?()

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
      requested = @require @name, "#{extension}/config"
      # Store all the paths
      paths.push @relToAbs @name, extension
      # Push a clone of the config file to remove reference
      configs.push @clone requested
      extension = requested.extends

    # Combine all the config files into one
    # The values of the config files from lower down the chain have piortiy
    result = configs[configs.length-1]
    for i in [configs.length-2..0]
      result = @combine result, configs[i]

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
    Module = @findModule @paths, name, surrogate
    module = @[name] = new Module @, @config[name], params...
    module.cuid = @uid
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
    Constructs the component and its modules using the addModule method
  ###
  init: ->
    # Call init on all the modules
    for name in @modules when name isnt "view" and item = @[name]
      item.init?()

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