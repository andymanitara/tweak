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

    @param [Object] context The contextual object of which the event to be binded to.
    @param [String, Array<String>] name The event name(s); split on a space, or an array of event names.
    @param [Function] callback The event callback function.
    @param [Number] max (Default = null). The maximum calls on the event listener. After the total calls the events callback will not invoke.

    @example Binding a callback to event(s) (JS)
      tweak.Events.addEvent(this, "sample:event", function(){
        alert("Sample event triggered.")
      });

    @example Adding event with Max Calls (JS)
      // This example will allow the event to be called twice.
      // The event will no longer trigger when the calls have reached its limit.
      tweak.Events.addEvent(this, "sample:event", function(){
        alert("Sample event triggered.")
      }, 2);

    @example Adding event (CoffeeScript)
      # This example will allow the event to be called twice.
      # The event will no longer trigger when the calls have reached its limit.
      tweak.Events.addEvent(@, "sample:event", ->
        alert "Sample event triggered."
      ,
      2)

      tweak.Events.addEvent(@, "sample:event", @testCallback, 2);
  ###
  addEvent: (context, name, callback, max = null) ->
    # Find the event / build the event path.
    for event in @find name, true
      for item in event.__callbacks ?= []
        # If the callback and context for an event match then ignore adding the event.
        if context isnt item.ctx and item.callback isnt callback
          event.__callbacks.push {ctx:context, callback, max, calls:0, listen:true}
    return

  ###
    Remove a previously bound callback function
    @param [Object] context The contextual object of which the event is binded to.
    @param [String] name The event name(s); split on a space, or an array of event names.
    @param [Function] callback (optional) The callback function of the event. If no specific callback is given then all the events under event name are removed.

    @example Unbinding a callback from event(s) (JS)
      tweak.Events.removeEvent(this, "sample:event another:event", @callback);

    @example Unbinding all callbacks from event(s) (JS)
      tweak.Events.removeEvent(this, "sample:event another:event");

  ###
  removeEvent: (context, name, callback) ->    
    for event in @find name
      # Check to see if the callback matches.
      # If event matches criteria then delete.
      for key, item of event.__callbacks
        if not callback? or context is item.ctx and callback is item.callback
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
            ,1)
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

