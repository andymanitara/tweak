###
  The controller should be used to control the logic and functionality between components modules.
  The controller allows for seperation for your logic. You can still use the view and the model ect to control logic, but think of this as your middle man/ blank canvas.
  By seperating the logic between the model and view you allow for much cleaner code. The view can still contain logic; but try keep this logic based on the interface between the user and view.

  The view could be used to define the parts of interaction; and animating things.
  The model can be used for validating data on updateing of data allowing a simple continuous checking system seperate from your logic.
  Therefore the complex logic between what happens on certain interaction can remain in the controller; making it simpler to understand what happens where and when.
  It now keeps your code clean from long and extensive validation and animation logic; which can make code hard to understand when trying to debug why something wont happen after another thing.
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
    Event 'on' handler for DOM and the Event API
    @param [String] name The event name, split on the / and : characters, to add
    @param [Function] callback  The callback function; if you do not include this then all events under the name will be removed
    @param [Number] maxCalls The maximum amount of calls the event can be triggered.
    @return [Boolean] Returns whether the event is added
  ###
  on: (params...) -> 
    tweak.Events.on @, params...
    return

  ###
    Event 'off' handler Event API
    @param [String] name The event name, split on the / and : characters, to remove
    @param [Function] callback (optional) The callback function; if you do not include this then all events under the name will be removed
    @return [Boolean] Returns whether the event is removed
  ###
  off: (params...) -> 
    tweak.Events.off @, params...
    return

  ###
    Event 'trigger' handler for DOM and the Event API, triggered in async
    @param [String] name The event name, split on the / and : characters, to trigger
    @param [...] params Parameters to pass into the callback function
  ###
  trigger: (params...) ->
    setTimeout(->
      tweak.Events.trigger params...
    ,0)
    return

  ###
    Set an event to either not listen or listen - default is to listen. Also can be used to modify event options.
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
