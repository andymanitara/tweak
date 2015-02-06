###
  Tweak.js is built in with an event system that can be used
  to bind/unbind and trigger events throughout modules and
  your application. This provides functionality to communicate
  simply and effectively while maintaining an organised structure
  to your code and applications.
 
  Examples are in JS, unless where CoffeeScript syntax may be unusual.
###
class tweak.EventSystem

  _events = {}

  ###
    Iterate through events to find matching named events.

    @overload find(name, params)
      Find events with a space separated string.
      @param [String] name The event name(s); split on a space.
      @param [Boolean] build (Default = false) Whether or not to add an event object when none can be found.
      @return [Array<Event>] All event objects that are found/created then it is returned in an Array.

    @overload find(names, params)
      Find events with an array of names (strings).
      @param [Array<String>] names An array of names (strings).
      @param [Boolean] build (Default = false) Whether or not to add an event object when none can be found.
      @return [Array<Event>] All event objects that are found/created then it is returned in an Array.

    @example Delimited string
      // This will find all events in the given space delimited string.
      tweak.Events.find("sample:event another:event");

    @example Delimited string with build
      // This will find all events in the given space delimited string.
      // If event can not be found then it will be created.
      tweak.Events.find("sample:event another:event", true);

    @example Array of names (strings)
      // This will find all events from the names in the given array.
      tweak.Events.find(["sample:event", "another:event"]);

    @example Array of names (strings) with build
      // This will find all events from the names in the given array.
      // If event can not be found then it will be created.
      tweak.Events.find(["sample:event", "another:event"], true);

  ###
  findEvent: (name, build = false) ->
    # Split name if it is a string
    if typeof name is "string"
      name = name.split /\s+/

    for item in name
      event = @events[name]
      if not event
        # If build is true then the event path with be added to the tree
        if build then event = {name:item}
        else continue
      event

  ###
    Bind a callback to the event system. The callback is invoked when an
    event is triggered. Events are added to an object based on their name.

    Name spacing is useful to separate events into their relevant types.
    It is typical to use colons for name spacing. However you can use any other
    namespacing characters such as / \ - _ or .

    @param [String, Array<String>] name The event name(s); split on a space, or an array of event names.
    @param [Function] callback The event callback function.
    @param [Number] max (Default = null). The maximum calls on the event listener. After the total calls the events callback will not invoke.
    @param [Object] context The contextual object of which the event to be binded to.

    @example Binding a callback to event(s) (JS)
      tweak.Events.addEvent("sample:event", function(){
        alert("Sample event triggered.")
      });

    @example Binding a callback to event(s) with a seperate context without limitation (JS)
      tweak.Events.addEvent("sample:event", function(){
        alert("Sample event triggered.")
      }, null, this);

    @example Binding a callback to event(s) with a seperate context with a Max calls (JS)
      tweak.Events.addEvent("sample:event", function(){
        alert("Sample event triggered.")
      }, 3, this);

  ###
  addEvent: (name, callback, max, context = @) ->
    # Find the event / build the event path.
    for event in @find name, true
      ignore = false
      for item in event.__callbacks ?= []
        # If the callback and context for an event match then ignore adding the event, but update the current event.
        if item.callback is callback and context is item.ctx
          # Update events max calls property
          item.max = max
          # Reset event calls and make event listen again
          item.calls = 0
          item.listen = ignore = true
      if ignore then event.__callbacks.push {ctx:context, callback, max, calls:0, listen:true}

    return

  ###
    Remove a previously bound callback function
    @param [String] name The event name(s); split on a space, or an array of event names.
    @param [Function] callback (optional) The callback function of the event. If no specific callback is given then all the events under event name are removed.
    @param [Object] context (default = this) The contextual object of which the event is binded to.

    @example Unbinding a callback from event(s) (JS)
      tweak.Events.removeEvent("sample:event another:event", @callback);

    @example Unbinding all callbacks from event(s) (JS)
      tweak.Events.removeEvent("sample:event another:event");
  ###
  removeEvent: (name, callback, context = @) ->
    for event in @find name
      # Check to see if the callback matches.
      # If event matches criteria then delete.
      for key, item of event.__callbacks
        if (not callback? or callback is item.callback) and (not context? or context is item.ctx) 
          delete event.__callbacks[key]
      if event.__callbacks.length is 0 then delete @events[event.name]
    return

  ###
    Trigger events by name.
    @overload triggerEvent(name, params)
      Trigger events by name only.
      @param [String, Array<String>] name The event name(s); split on a space, or an array of event names.
      @param [...] params Params to pass into the callback function.

    @overload triggerEvent(options, params)
      Trigger events by name and context.
      @param [Object] options Options and limiters to check against callbacks.
      @param [...] params Params to pass into the callback function.
      @option options [String, Array<String>] names The event name(s); split on a space, or an array of event names.
      @option options [Boolean] async (default = true) Whether to trigger asynchronously.
      @option options [Context] context The context of the callback to check against a callback.

    @example Triggering event(s) (JS)
      tweak.Events.triggerEvent("sample:event, another:event");

    @example Triggering event(s) with params (JS)
      tweak.Events.triggerEvent("sample:event another:event", "whats my name", "its...");

    @example Triggering event(s) but only with matching context (JS)
      tweak.Events.triggerEvent({context:@, name:"sample:event another:event"});

    @example Triggering event(s) syncronously (JS)
      tweak.Events.triggerEvent({async:false, name:"sample:event another:event"});
  ###
  triggerEvent: (name, params...) ->
    async = true
    if typeof name is "object" and not name instanceof Array
      name = name.name or []
      context = name.context
      if name.aysnc? then async = name.async 
    
    for event in @find name
      for item in event.__callbacks
        if item.listen and (not context? or context is item.ctx)
          # Check to see if the event has reached its call limit
          # If it has reached its limit delete or add another.
          if item.max? and ++item.calls >= item.max            
            item.listen = false
          if async
            setTimeout(->
              item.callback.call item.ctx, params...
            ,0)
          else item.callback.call item.ctx, params...
            
    return

  ###
    Set events listening state, max calls, and total calls limited by name and options (callback, context).
    @param [String] name The event name(s); split on a space, or an array of event names.
    @param [Object] options The limits to check events to.
    @option options [Object] context Context to limit to.
    @option options [Function] callback Callback function to limit to.
    @option options [Number] max Set a new maximum calls to an event.
    @option options [Number] calls Set the amount of calls that has been triggered on this event.
    @option options [Boolean] reset (Default = false) If true then calls on an event get set back to 0.
    @option options [Boolean] listen Whether to enable or disable listening to event.

    @example Updating event(s) to not listen (JS)
      tweak.Events.updateEvent("sample:event, another:event", {listen:false});

    @example Updating event(s) to not listen, however limited by optional context and/or callback (JS)
      // Limit events that match to a context and callback.
      tweak.Events.updateEvent("sample:event, another:event", {context:@, callback:@callback, listen:false});

      // Limit events that match to a callback.
      tweak.Events.updateEvent("sample:event, another:event", {callback:@anotherCallback, listen:false});

      // Limit events that match to a context.
      tweak.Events.updateEvent("sample:event, another:event", {context:@, listen:false});

    @example Updating event(s) max calls and reset its current calls (JS)
      tweak.Events.updateEvent("sample:event, another:event", {reset:true, max:100});

    @example Updating event(s) total calls (JS)
      tweak.Events.updateEvent("sample:event, another:event", {calls:29});
  ###
  updateEvent: (name, options = {}) ->
    ctx = options.context
    max = options.max
    reset = options.reset
    calls = if reset then 0 else options.calls or 0
    listen = options.listen
    callback = options.callback
    for event in @find name
      for item in event.__callbacks
        if (not ctx? or ctx isnt item.ctx) and (not callback? or callback isnt item.callback)
          if max? then item.max = max
          if calls? then item.calls = calls
          if listen? then item.listen = listen    
    return

  ###
    Resets the event object tree back to empty.
  ###
  resetEvents: -> @events = {}

# A global events object is automatically created. Allowing for global event handling.
tweak.Events = new tweak.EventSystem()

