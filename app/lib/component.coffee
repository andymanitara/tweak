###
  tweak.component.js 1.0.6

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###

###
  The future of MVC doesn't always lie in web applications; the architecture to
  TweakJS allows for integration of components anywhere on a website. For example
  you can plug "Web Components" into your static site; like sliders, accordions.
  The flexibility is endless; allowing MVC to be used from small web components
  to full scale one page web applications.

  TweakJS wraps its Models, Views, Templates, and Controllers into a Component
  module. The Component module acts intelligently to build up your application
  with simple configuration files. Each Component its built through a config
  object; this allows for powerful configuration with tonnes of flexibility.
  The config objects are extremely handy for making Components reusable, with
  easy accessible configuration settings.

  Each Component can have sub Components which are accessible in both directions;
  although it is recommended to keep functionality separate it sometimes comes in
  handy to have access to other parts of the application. Each Component can
  extend another Component, which will then inherent the models, views, templates,
  and controllers directly from that Component. If you however want to extend a
  Component using a different Model you can simply overwrite that model, or extend
  the functionality to the inherited model Components model.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
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
  # @property [Interger] The uid of this object - for unique reference.
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
  # @property [Method] see tweak.super
  super: tweak.super

  modules: ["controller", "model", "view", "router", "components"]

  ###
    @param [Object] relation Relation to the Component.
    @param [Object] options Configuration for the Component.
  ###
  constructor: (relation, options) ->
    if not options? then throw new Error "No options given"

    # Set uid
    @uid = "c_#{tweak.uids.c++}"
    # Build relation if window and build its default properties
    # The relation is it direct caller
    relation = @relation = if relation is window then {} else relation
    relation.relation ?= {}
    # Get parent Component
    @parent = if relation instanceof tweak.Component then relation else relation.component or relation
    @root = @parent.root or @
    # Set name of Component
    @name = options.name
    if not @name? then throw new Error "No name given"

    @config = @__buildConfig(options) or {}
    # Router is optional as it is performance heavy
    # So it needs to be explicitly defined in the config for the Component that it should be used
    if @config.router then @__addRouter()

    # Add modules to the Component
    @__addModel()
    @__addView()
    @__addComponents()
    @__addController()

    # Add references to the the modules
    for name in @modules when prop = @[name]
      prop.parent = @parent
      prop.component = @
      for name2 in @modules when name isnt name2 and prop2 = @[name2]
        prop[name2] = prop2

  ###
    When the component is initialised it's modules are also initialised.
  ###
  init: ->
    # Call init on all the modules
    for name in @modules when name isnt "view" and item = @[name]
      item.init?()
    return

  ###
    @private
    Builds the configuration object for the Component.
    @param [Object] options Component options.
    @return [Object] Combined config based on the components inheritance.
  ###
  __buildConfig: (options) ->
    configs = []
    paths = @paths = []

    extension = @name
    if options
      strict = options.strict ?= true
      configs.push @clone options
      if options.extends then extension = options.extends

    # Gets all configs, by configs extension path
    name = @parent?.name or @name
    while extension
      requested = @require name, "#{extension}/config", if strict then null else {}
      # Store all the paths
      paths.push @relToAbs name, extension
      # Push a clone of the config file to remove reference
      configs.push @clone requested
      extension = requested.extends

    # Combine all the config files into one
    # The values of the config files from lower down the chain have priority
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
    @private
    Add a module to the Component, if module can't be found then it will use a surrogate object.
    @param [String] name Name of the module.
    @param [Object] surrogate Surrogate if the module can not be found.
    @param [...] params Parameters passed into the module on construction.
  ###
  __addModule: (name, surrogate, params...) ->
    Module = @findModule @paths, "./#{name}", surrogate
    module = @[name] = new Module @config[name], params...
    module.component = @
    module.root = @root
    return

  ###
    @private
    Short cut method to adding view using the addModule method.
    @param [...] params Parameters passed to into the view constructor.
  ###
  __addView: (params...) ->
    @__addModule "view", tweak.View, params...
    return

  ###
    @private
    Short cut method to adding Model using the addModule method.
    @param [...] params Parameters passed to into the model constructor.
  ###
  __addModel: (params...) ->
    @__addModule "model", tweak.Model, params...
    return

  ###
    @private
    Short cut method to adding controller using the addModule method.
    @param [...] params Parameters passed to into the controller constructor.
  ###
  __addController: (params...) ->
    @__addModule "controller", tweak.Controller, params...
    return

  ###
    @private
    Add module to this Component.
    @param [...] params Parameters passed to into the Components constructor.
  ###
  __addComponents: ->
    name = "components"
    Module = @findModule @paths, "./#{name}", tweak.Components
    module = @[name] = new Module @, @config[name]
    return

  ###
    @private
    Short cut method to adding router using the addModule method.
    @param [...] params Parameters passed to into the router constructor.
  ###
  __addRouter: (params...) ->
    @__addModule "router", tweak.Router, params...
    return

  ###
    @private
    Reusable method to render and re-render.
    @param [String] type The type of rendering to do either "render" or "rerender".
  ###
  __componentRender: (type) ->
    @view.addEvent "#{type}ed", ->
      @components.addEvent "ready", ->
        @controller.triggerEvent "ready"
      , @, 1
      @components[type]()
    , @, 1
    @view[type]()
    return

  ###
    Renders itself and its subcomponents.
    @event ready Triggers ready event when itself and its Components are ready/rendered.
  ###
  render: ->
    name = @name
    @__componentRender "render"
    return

  ###
    Re-renders itself and its subcomponents.
    @event ready Triggers ready event when itself and its Components are ready/re-rendered.
  ###
  rerender: ->
    @__componentRender "rerender"
    return

  ###
    Destroy this Component. It will clear the view if it exists; and removes it from the Components Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
  ###
  destroy: (silent) ->
    @view.clear()
    components = @relation.components
    if components?
      i = 0
      for item in components.data
        if item.uid is @uid
          components.remove i, silent
          return
        i++
    return

  ###
    Short-cut to the controllers findEvent method.

    @overload findEvent(names, build)
      Find events on controller with a space separated string.
      @param [String] names The event name(s); split on a space.
      @param [Boolean] build (Default = false) Whether or not to add an event object to the controller when none can be found.
      @return [Array<Event>] All event objects that are found/created then it is returned in an Array.

    @overload findEvent(names, build)
      Find events on controller with an array of names (strings).
      @param [Array<String>] names An array of names (strings).
      @param [Boolean] build (Default = false) Whether or not to add an event object to the controller when none can be found.
      @return [Array<Event>] All the controllers event objects that are found/created then it is returned in an Array.
  ###
  findEvent: (names, build) -> @controller.findEvent names, build
    

  ###
    Short-cut to the controllers addEvent method.

    @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
    @param [Function] callback The event callback function.
    @param [Number] maximum (Default = null). The maximum calls on the event listener. After the total calls the events callback will not invoke.
    @param [Object] context The contextual object of which the event to be bound to.
  ###
  addEvent: (names, callback, max, context) -> @controller.addEvent names, callback, max, context

  ###
    Short cut to the controllers removeEvent method.

    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Function] callback (optional) The callback function of the event. If no specific callbacki s given then all the controller events under event name are removed.
    @param [Object] context (default = this) The contextual object of which the event is bound to. If this matches then it will be removed, however if set to null then all events no matter of context will be removed.
  ###
  removeEvent: (names, callback, context) -> @controller.removeEvent names, callback, context

  ###
    Short cut to the controllers triggerEvent method.

    @overload triggerEvent(names, params)
      Trigger events on controller by name only.
      @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @param [...] params Parameters to pass into the callback function.

    @overload triggerEvent(options, params)
      Trigger events on controller by name and context.
      @param [Object] options Options and limiters to check against callbacks.
      @param [...] params Parameters to pass into the callback function.
      @option options [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @option options [Context] context (Default = null) The context of the callback to check against a callback.
  ###
  triggerEvent: (names, params...) -> @controller.triggerEvent names, params...

  ###
    Shortcut to the controllers updateEvent method.

    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Object] options Optional limiters and update values.
    @option options [Object] context The contextual object to limit updating events to.
    @option options [Function] callback Callback function to limit updating events to.
    @option options [Number] max Set a new maximum calls to an event.
    @option options [Number] calls Set the amount of calls that has been triggered on this event.
    @option options [Boolean] reset (Default = false) If true then calls on an event get set back to 0.
    @option options [Boolean] listen Whether to enable or disable listening to event.
  ###
  updateEvent: (names, options) -> @controller.updateEvent names, options

  ###
    Resets the controllers events to empty.
  ###
  resetEvents: -> @controller.resetEvents()