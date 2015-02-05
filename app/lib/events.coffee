###
  Tweak.js is built in with an event system that can be used to bind/unbind and trigger events throughout modules and your application. 
  This provides functionality to communicate simply and effectively while maintaining an organised structure to your code and applications.

  The event system simply stores the callbacks in an object tree. 
  The object tree allowing for quick traversal to events, speeding up overall event triggers. 
  Each node of the tree when accessing an event is spit upon the / \ : and . characters. 
  The splitting of events on these characters increases flexibility in ow you name your events.
  
  Events can be filtered by its context and callback, allowing you to control individual event callbacks or all callbacks under a registered event.
  Events have a listen property to pause/unpause listening.
  Set a max amount of calls to an event before it will automatically no longer listens.
  Update a Events properties quickly and easily. Properties: Max calls, current total calls and listen.
###
class tweak.Events
  # @property [Integer] The component uid of this object - for unique reference of component
  uid: 0

  super: tweak.super
  
  # Split regex for event name
  splitEventName = (name) ->
    if typeof name is "string"
      return name.split /[\/\\:.]/
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
  on: (ctx, name, callback, max = null) ->
    # If there is no callback then return from function
    if not callback? then return false
    # Find the event / build the event path
    event = @find name, true
    # Check if to replace current event
    # Convert callback to string for extra check for events that may be directly bound
    callbackString = callback.toString()
    for key, item of event.__callbacks ?= []
      if ctx is item.ctx and (item.callback is callback or callbackString is item.callback.toString())
        replace = key
        break
        
    obj = {ctx, callback, max, calls:0, listen:true}
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
    # Convert callback to string for extra check for events that may be directly bound
    result = false
    callbackString = callback.toString()
    for key, item of event.__callbacks
      if context is item.ctx and (callback is item.callback or callbackString is item.callback.toString())
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
    # Assign common parameters to variables. 
    for key, item of callbacks
      if not item.listen or (context and item.ctx isnt context) then continue
      # Check to see if the event has reached its call limit
      # Delete event if reached call limit
      if item.max? and ++item.calls >= item.max then item.listen = false
      item.callback.call item.ctx, params...
    return      
  
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
    Set events listening state, max calls, and total calls limited by name and options (callback, context).
    @param [String] name The event name; split on the / and : characters
    @param [Object] options The limits to check events to.
    @option options [Object] context Context to limit to.
    @option options [Function] callback Callback function to limit to.
    @option options [Number] max Set a new maximum calls to an event.
    @option options [Number] calls Set the amount of calls that has been triggered on this event.
    @option options [Boolean] reset (Default = false) If true then calls on an event get set back to 0.
    @option options [Boolean] listen Whether to enable or disable listening to event.
  ###
  set: (name, options = {}) ->
    event = @find name
    return false if not event?.__callbacks
    callbacks = event.__callbacks
    c = options.context
    m = options.max
    r = options.reset
    cl = if r then 0 else options.calls or 0

    l = options.listen
    ca = options.callback
    cs = if ca then ca.toString() else null
    for key, item of callbacks
      if (c? and item.ctx isnt c) or (cs? and item.callback.toString() isnt cs) then continue
      if m? then item.max = m
      if cl? then item.calls = cl
      if l? then item.listen = l
    true

  ###
    Resets the event object tree back to empty.
  ###
  reset: -> @events = {}

### 
  Initialise Event System. This is only needed the once.
  To stop multiple instances of it being declared it is overwritten as it constructed version.
###
tweak.Events = new tweak.Events()