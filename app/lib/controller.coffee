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
  constructor: (@relation, @config = {}) ->
    # Set uid
    @uid = "ct_#{tweak.uids.ct++}"
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
  on: (params...) -> tweak.Events.on @, params...

  ###
    Event 'off' handler Event API
    @param [String] name The event name, split on the / and : characters, to remove
    @param [Function] callback (optional) The callback function; if you do not include this then all events under the name will be removed
    @return [Boolean] Returns whether the event is removed
  ###
  off: (params...) -> tweak.Events.off @, params...

  ###
    Event 'trigger' handler for DOM and the Event API, triggered in async
    @param [String] name The event name, split on the / and : characters, to trigger
    @param [...] params Parameters to pass into the callback function
  ###
  trigger: (params...) ->
    setTimeout(->
      tweak.Events.trigger params...
    ,0)

  ###
    Set event to be listened to
    @param [String] name The event name; split on the / and : characters
    @param [Object] options The limits to check events to.
    @option options [Object] context Context to limit to.
    @option options [Function] callback Callback function to limit to.
    @option options [Number] max Maximum calls to limit to.
  ###
  listen: (name, options = {}) ->
    options.listen = true
    tweak.Events.toggle name, options

  ###
    Set event to not be listened to
    @param [String] name The event name; split on the / and : characters
    @param [Object] options The limits to check events to.
    @option options [Object] context Context to limit to.
    @option options [Function] callback Callback function to limit to.
    @option options [Number] max Maximum calls to limit to.
  ###
  noListen: (name, options = {}) ->
    options.listen = false
    tweak.Events.toggle name, options