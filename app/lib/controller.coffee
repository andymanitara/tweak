###
  A Controller defines the business logic between other modules. It can be used to
  control data flow, logic and more. It should process the data from the Model, 
  interactions and responses from the View, and control the logic between other 
  modules. The Controller has quick access to the **event system** and thus it can
  use this functionality to keep control of events that happen throughout your 
  application, Components and modules.
###
class tweak.Controller

  # @property [Interger] The uid of this object - for unique reference
  uid: 0
  # @property [*] The root relationship to this module
  root: null
  # @property [*] The direct relationship to this module
  relation: null

  # @private
  constructor: (relation, config = {}) ->
    # Set uid
    @uid = "ct_#{tweak.uids.ct++}"
    @relation = relation ?= {}
    @root = relation.root or @
    @name = config.name or relation.name

  ###
    Default initialiser function
  ###
  init: ->

  ###
    A shortcut to the event systems, event binding function. For more information see the Events Class.

    @param [Object] context The contextual object of which the event to be binded to.
    @param [String] name The event name(s); split on a space, or an array of event names.
    @param [Function] callback The event callback function.
    @param [Number] max (Default = null). The maximum calls on the event listener. After the total calls the events callback will not invoke.
  ###
  on: (context, name, callback, max) ->
    tweak.Events.on context, name, callback, max
    return

  ###    
    A shortcut to the event systems, event unbinding function. For more information see the Events Class.

    @param [Object] context The contextual object of which the event is binded to.
    @param [String] name The event name(s); split on a space, or an array of event names.
    @param [Function] callback (optional) The callback function of the event. If no specific callback is given then all the events under event name are removed.
  ###
  off: (context, name, callback) ->
    tweak.Events.off context, name, callback
    return

  ###
    A shortcut to the event systems, event triggering function. For more information see the Events Class.
    The event is triggered in an async manner through this shortcut.

    @overload trigger(name, params)
      Trigger events by name only.
      @param [String, Array<String>] name The event name(s); split on a space, or an array of event names.
      @param [...] params Params to pass into the callback function.

    @overload trigger(options, params)
      Trigger events by name and context.
      @param [Object] options Options and limiters to check against callbacks.
      @param [...] params Params to pass into the callback function.
      @option options [String, Array<String>] names The event name(s); split on a space, or an array of event names.
      @option options [Context] context The context of the callback to check against a callback.
  ###
  trigger: (name, args...) ->
    setTimeout(->
      tweak.Events.trigger name, args...
    ,0)
    return

  ###
    A shortcut to the event systems, event updating function. For more information see the Events Class.
    Primarily to set an event to either not listen or listen - default is to listen. Also can be used to modify event options.

    @param [String] name The event name; split on the / and : characters
    @param [Object] options The limits to check events to.    
    @option options [Object] context Context to limit to.
    @option options [Function] callback Callback function to limit to.
    @option options [Function] listen Whether to enable or disable listening to event.
    @option options [Number] max Set a new maximum calls to an event.
    @option options [Number] calls Set the amount of calls that has been triggered on this event.
    @option options [Boolean] reset (Default = false) If true then calls on an event get set back to 0.
  ###
  listen: (name, options) ->
    options.listen ?= true
    tweak.Events.set name, options
    return
