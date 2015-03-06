###
  Tweak.js has an event system class, this provides functionality to extending classes to communicate simply and
  effectively while maintaining an organised structure to your code and applications. Each object can extend the
  tweak.EventSystem class to provide event functionality to classes. Majority of Tweak.js modules/classes already
  extend the EventSystem class, however when creating custom objects/classes you can extend the class using the
  tweak.Extends method, please see the Class class in the documentation.
    
  Examples are in JS, unless where CoffeeScript syntax may be unusual.
###
class tweak.EventSystem
  ###
    Iterate through events to find matching named events. Can be used to add a new event through the optional Boolean build argument

    @overload findEvent(names, build)
      Find events with a space separated string.
      @param [String] names The event name(s); split on a space.
      @param [Boolean] build (Default = false) Whether or not to add an event object when none can be found.
      @return [Array<Event>] All event objects that are found/created then it is returned in an Array.

    @overload findEvent(names, build)
      Find events with an array of names (strings).
      @param [Array<String>] names An array of names (strings).
      @param [Boolean] build (Default = false) Whether or not to add an event object when none can be found.
      @return [Array<Event>] All event objects that are found/created then it is returned in an Array.

    @example Delimited string
      // This will find all events in the given space delimited string.
      tweak.Events.findEvent("sample:event another:event");

    @example Delimited string with build
      // This will find all events in the given space delimited string.
      // If event can not be found then it will be created.
      tweak.Events.findEvent("sample:event another:event", true);

    @example Array of names (strings)
      // This will find all events from the names in the given array.
      tweak.Events.findEvent(["sample:event", "another:event"]);

    @example Array of names (strings) with build
      // This will find all events from the names in the given array.
      // If event can not be found then it will be created.
      tweak.Events.findEvent(["sample:event", "another:event"], true);

  ###
  findEvent: (names, build = false) ->
    # Split name if it is a string
    if typeof names is "string"
      names = names.split /\s+/
    # Initiate @__events property if not yet initialised
    events = @__events = @__events or {}
    # Search for each name
    for item in names
      # Check if event exists
      if not event = events[item]
        # If we are to build then add a default event else continue the iteration
        if build then event = @__events[item] = {name:item, __callbacks:[]}
        else continue
      # Push found/created event into the returning array
      event

  ###
    Bind a callback to the event system. The callback is invoked when an
    event is triggered. Events are added to an object based on their name.

    Name spacing is useful to separate events into their relevant types.
    It is typical to use colons for name spacing. However you can use any other
    namespacing characters such as / \ - _ or .

    @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
    @param [Function] callback The event callback function.
    @param [Number] max (Default = null). The maximum calls on the event listener. After the total calls the events callback will not invoke.
    @param [Object] context The contextual object of which the event to be binded to.

    @example Binding a callback to event(s) (JS)
      tweak.Events.addEvent("sample:event", function(){
        alert("Sample event triggered.")
      });

    @example Binding a callback to event(s) with a separate context without limitation or total calls (JS)
      tweak.Events.addEvent("sample:event", function(){
        alert("Sample event triggered.")
      }, null, this);

    @example Binding a callback to event(s) with a separate context with max calls (JS)
      tweak.Events.addEvent("sample:event", function(){
        alert("Sample event triggered.")
      }, 3, this);

  ###
  addEvent: (names, callback, max, context = @) ->
    # Find events / build the event path, then iterate through them.
    for event in @findEvent names, true
      ignore = false
      # Iterate through all callbacks to this event
      for item in event.__callbacks
        # If the callback and context for an event match then ignore adding the event, but update the current event.
        if item.callback is callback and context is item.ctx
          # Update events max calls property
          item.max = max
          # Reset event calls and make event listen again
          item.calls = 0
          item.listen = ignore = true
      if not ignore then event.__callbacks.push {ctx:context, callback, max, calls:0, listen:true}
    return

  ###
    Remove a previously bound callback function. Removing events can be limited to context and its callback.
    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Function] callback (optional) The callback function of the event. If no specific callback is given then all the events under event name are removed.
    @param [Object] context (default = this) The contextual object of which the event is binded to. If this matches then it will be removed, however if set to null then all events no matter of context will be removed.

    @example Unbinding a callback from event(s) (JS)
      tweak.Events.removeEvent("sample:event another:event", @callback);

    @example Unbinding all callbacks from event(s) (JS)
      tweak.Events.removeEvent("sample:event another:event");
  ###
  removeEvent: (names, callback, context = @) ->
    # Iterate through found events
    for event in @findEvent names
      # Check to see if the callback and/or context matches.
      # If event matches criteria then delete.
      for key, item of event.__callbacks
        if (not callback? or callback is item.callback) and (not context? or context is item.ctx)
          event.__callbacks.splice key,1
      # If callbacks is empty then delete from @__events object
      if event.__callbacks.length is 0
        delete @__events[event.name]

    return

  ###
    Trigger events by name.
    @overload triggerEvent(names, params)
      Trigger events by name only.
      @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @param [...] params Params to pass into the callback function.

    @overload triggerEvent(options, params)
      Trigger events by name and context.
      @param [Object] options Options and limiters to check against callbacks.
      @param [...] params Params to pass into the callback function.
      @option options [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @option options [Context] context (Default = null) The context of the callback to check against a callback.

    @example Triggering event(s) (JS)
      tweak.Events.triggerEvent("sample:event, another:event");

    @example Triggering event(s) with params (JS)
      tweak.Events.triggerEvent("sample:event another:event", "whats my name", "its...");

    @example Triggering event(s) but only with matching context (JS)
      tweak.Events.triggerEvent({context:@, name:"sample:event another:event"});
  ###
  triggerEvent: (names, params...) ->
    # If names is an object then set names and context
    if typeof names is "object" and not names instanceof Array
      names = names.names or []
      context = names.context or null

    # Iterate through found events
    for event in @findEvent names
      # Iterate through this event's callbacks
      for item in event.__callbacks
        # If in listening state and if there is a context limit calls to the events with matching context
        if item.listen and (not context? or context is item.ctx)
          # Update the total calls to this event callback
          if item.max? and ++item.calls >= item.max
            # Event has hit call limit, so set its event listening state to false
            item.listen = false
          # Call the events call back
          setTimeout ->
            item.callback.apply item.ctx, params
            return
          ,0
    return

  ###
    Set events listening state, max calls, and total calls limited by name and options (callback, context).
    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Object] options Optional limiters and update values.
    @option options [Object] context The contextual object to limit updating events to.
    @option options [Function] callback Callback function to limit updating events to.
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
  updateEvent: (names, options = {}) ->
    # Setup limiters and update properties
    ctx = options.context
    max = options.max
    reset = options.reset
    calls = if reset then 0 else options.calls or 0
    listen = options.listen
    callback = options.callback

    # Iterate through found events
    for event in @findEvent names
      # Iterate through this event's callbacks
      for item in event.__callbacks
        # Check to see if the callback and/or context matches.
        if (not ctx? or ctx isnt item.ctx) and (not callback? or callback isnt item.callback)
          # Update event properties
          if max? then item.max = max
          if calls? then item.calls = calls
          if listen? then item.listen = listen
    return

  ###
    Resets the events on this object to empty.
  ###
  resetEvents: -> @__events = {}

# A global events object is automatically created. Allowing for global event handling.
tweak.Events = new tweak.EventSystem()