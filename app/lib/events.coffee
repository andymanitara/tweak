###
  The framework is driven by a powerful and simple event system.

  The event system simply stores the callbacks in an object tree.
  The tree allows quick traversal of events, during interaction with the event API
###
class tweak.EventSystem
  # Split regex for event name
  splitEventName = (name) ->
    if typeof name is "string"
      return name.split(/[\/:]/)
    else if name instanceof Array
      return name
    else throw new Error "Event name not parsable"

  # Initialise the event object
  events: {}

  # @private
  constructor: -> @reset()

  ###
    Add an event listener into the event system.
    The event system will store the object based on its event name
    
    @param [Object] context The contextual object of which the event to be binded to
    @param [String] name The event name; split on the / and : characters
    @param [Function] callback The event callback
    @param [Number] maxCalls Default=null. The maximum calls allowed on the event listener

    @example Sample Event (JS)
      tweak.Events.on(this, "sample/event", function(){
        alert("Sample event triggered.")
      })

    @example Sample Event (CoffeeScript)
      tweak.Events.on @, "sample/event", ->
        alert "Sample event triggered."

    @example Sample Event with Max Calls (JS)
      // This example will allow the event to be called twice
      // The event is automatically removed from the event object on max calls
      tweak.Events.on(this, "sample/event", function(){
        alert("Sample event triggered.")
      }, 2)

    @example Sample Event (CoffeeScript)
      // This example will allow the event to be called twice
      // The event is automatically removed from the event object on max calls
      tweak.Events.on(@, "sample/event", ->
        alert "Sample event triggered."
      ,
      2)

    @return [Boolean] Returns true if added, or false if not added
  ###
  on: (context, name, callback, maxCalls = null) ->
    # If there is no callback then return from function
    if not callback? then return false
    # Find the event / build the event path
    event = @find(name, true)
    # Convert callback to string;
    # This is used as a saftey device to prevent multiple events being added which call the same function
    callbackString = callback.toString()
    for item in event.__callbacks ?= []
      if item? and context is item.context and item.callback.toString() is callbackString then return false
    event.__callbacks.push({context, callback, maxCalls, calls:0})
    true

  ###
    Remove from events by given name
    @param [Object] context The contextual object of which the event is binded to
    @param [String] name The event name; split on the / and : characters
    @param [Function] callback (optional) The callback function of the event. If no specific callback is given then all the events under event name are removed
    @return [Boolean] Returns true if event(s) are removed, or false if no event are removed
  ###
  off: (context, name, callback) ->
    event = @find(name)
    # Return false if there is no event
    return false if not event?.__callbacks

    # If callback isnt specified then clear the callbacks and return true
    if not callback?
      event.__callbacks = []
      return true

    # Check to see if the callback matches
    # If event matches critera then delete and return true
    callbackString = callback.toString()
    for key, item of event.__callbacks
      if context is item.context and callbackString is item.callback.toString()
        delete event.__callbacks[key]
        return true
    false

  ###
    Trigger events by name
    @overload trigger(name, params)
      Trigger events by name only
      @param [String] name The event name; split on the / and : characters
      @param [...] params Params to pass into the callback function
      @return [Boolean] Returns true if event is triggered and false if nothing is triggered
    @overload trigger(obj, params)
      Trigger events by name and context
      @param [Object] obj {name:String (name of the event), context:Object (context of the event)}
      @param [...] params Params to pass into the callback function
      @return [Boolean] Returns true if event is triggered and false if nothing is triggered
  ###
  trigger: (name, params...) ->
    if typeof name is "object"
      context = name.context
      name = name.name or name.event or ""

    event = @find(name)
    return false if not event?.__callbacks
    callbacks = event.__callbacks
    called = false
    for key, item of callbacks
      if context and item.context isnt context then continue
      item.callback.call item.context, params...
      called = true
      # Check to see if the event has reached its call limit
      # Delete event if reached call limit
      if item.maxCalls?
        item.calls++
        if item.calls >= item.maxCalls
          delete callbacks[key]
    called
  
  ###
    Iterate through the events to find given event
    @param [String] name The event name; split on the / and : characters
    @param [Boolean] build Default = true. If set to true the event object will be built by the name if can be found.
    @return [Event, Null] If event object is found/created then it is returned.
  ###
  find: (name, build = false) ->
    # Split the name of event
    name = splitEventName(name)
    # Iterate through the event object
    event = @events
    for item in name
      if not event[item]
        # If build is true then the event path with be added to the tree
        if build
          event[item] = {__parent:event}
        else
          # If the event cant be found then return null
          return null
      event = event[item]
    # Return the event object
    event
  
  ###
    Resets the events back to empty.
  ###
  reset: -> @events = {}

### Initialise EventSystem ###
tweak.Events = new tweak.EventSystem()