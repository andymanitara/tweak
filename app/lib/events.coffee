###
  The framework is driven by a powerful and simple event system.

  The event system simply stores the callbacks in an object tree.
  The tree allows quick traversal of events, during interaction with the event API
###
class tweak.EventSystem
  # @property [Integer] The component uid of this object - for unique reference of component
  uid: 0
  # Split regex for event name
  splitEventName = (name) ->
    if typeof name is "string"
      return name.split /[\/:]/
    else if name instanceof Array
      return name
    else throw new Error "Event name not parsable"

  # Initialise the event object
  events: {}

  # @private
  constructor: ->
    # Set uid
    @uid = "e_#{tweak.uids.e++}"
    @reset()

  ###
    Add an event listener into the event system.
    The event system will store the object based on its event name
    
    @param [Object] context The contextual object of which the event to be binded to
    @param [String] name The event name; split on the / and : characters
    @param [Function] callback The event callback
    @param [Number] max Default=null. The maximum calls allowed on the event listener

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
  on: (context, name, callback, max = null) ->
    # If there is no callback then return from function
    if not callback? then return false
    # Find the event / build the event path
    event = @find name, true
    # Check if to replace current event
    for key, item of event.__callbacks ?= []
      if context is item.context and item.callback is callback
        replace = key
        break
        
    obj = {context, callback, max, calls:0, listen:true}
    if replace? then event.__callbacks[replace] = obj else event.__callbacks.push obj
    true

  ###
    Remove from events by given name
    @param [Object] context The contextual object of which the event is binded to
    @param [String] name The event name; split on the / and : characters
    @param [Function] callback (optional) The callback function of the event. If no specific callback is given then all the events under event name are removed
    @return [Boolean] Returns true if event(s) are removed, or false if no events are removed
  ###
  off: (context, name, callback) ->
    event = @find name
    # Return false if there is no event
    return false if not event?.__callbacks

    # If callback isnt specified then clear the callbacks and return true
    if not callback?
      event.__callbacks = []
      return true

    # Check to see if the callback matches
    # If event matches critera then delete and return true
    result = false
    for key, item of event.__callbacks
      if context is item.context and callback is item.callback
        delete event.__callbacks[key]
        result = true
    result

  ###
    Trigger events by name
    @overload trigger(name, params)
      Trigger events by name only
      @param [String] name The event name; split on the / and : characters
      @param [...] params Params to pass into the callback function
    @overload trigger(obj, params)
      Trigger events by name and context
      @param [Object] obj {name:String (name of the event), context:Object (context of the event)}
      @param [...] params Params to pass into the callback function
  ###
  trigger: (name, params...) ->
    if typeof name is "object"
      context = name.context
      name = name.name or name.event or ""
    event = @find name
    return if not event?.__callbacks
    callbacks = event.__callbacks
    for key, item of callbacks
      if not item.listen or (context and item.context isnt context) then continue
      item.callback.call item.context, params...
      # Check to see if the event has reached its call limit
      # Delete event if reached call limit
      if item.max?
        item.calls++
        if item.calls >= item.max
          delete callbacks[key]
  
  ###
    Iterate through the events to find given event
    @param [String] name The event name; split on the / and : characters
    @param [Boolean] build Default = true. If set to true the event object will be built by the name if can be found.
    @return [Event, Null] If event object is found/created then it is returned.
  ###
  find: (name, build = false) ->
    # Split the name of event
    name = splitEventName name
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
    Toggle events listening state limited by name and options (callback, context and max calls)
    @param [String] name The event name; split on the / and : characters
    @param [Object] options The limits to check events to.
    @option options [Object] context Context to limit to.
    @option options [Function] callback Callback function to limit to.
    @option options [Number] max Maximum calls to limit to.
    @option options [Function] listen Whether to enable listening to event.
  ###
  toggle: (name, options = {}) ->
    event = @find name
    return if not event?.__callbacks
    callbacks = event.__callbacks
    c = options.context
    ca = options.callback
    m = options.max
    l = options.listen
    for key, item of callbacks
      if (l? and item.listen is l) or (c and item.context isnt c) or (ca and item.callback isnt ca) or (m and item.max isnt m) then continue
      item.paused = not if l? then l else item.paused

  ###
    Resets the events back to empty.
  ###
  reset: -> @events = {}

### Initialise EventSystem ###
tweak.Events = new tweak.EventSystem()