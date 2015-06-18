###
  Tweak.js has an event system class, this provides functionality to extending classes to communicate simply and
  effectively while maintaining an organised structure to your code and applications. Each object can extend the
  Tweak.EventSystem class to inherit event functionality. Majority of Tweak.js modules/classes already extend
  the EventSystem class, however when creating custom objects/classes you can extend the class using the Tweak.extends
  method or your chosen language's extends method.
  
  The event system is bound to an object instance that extends the Tweak.Events Class. By bounding a Event system to
  an instance you keep your event structure focused and accurate; avoiding confusion with complex event scopes. Event
  names can be name spaced by any character, but you should keep the same name spacing structure as each structure will
  be treated as unique. The typical character is to use is a ':'; so an example of a event name will be 'changed:name'.

  Examples are not exact, and will not directly represent valid code; the aim of an example is to be a rough guide. JS
  is chosen as the default language to represent Tweak.js as those using 'compile-to-languages' should have a good
  understanding of JS and be able to translate the examples to a chosen language. Support can be found through the
  community if needed. Please see our Gitter community for more help {http://gitter.im/blake-newman/TweakJS}.
###
class Tweak.Events
  
  ###
    Iterate through bound events to find matching events. The method can also be used to construct an event by passing
    an optional true value Boolean argument.

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
      var model;
      model = new Model();
      model.findEvent('sample:event another:event');

    @example Delimited string with build
      // This will find all events in the given space delimited string.
      // If event cannot be found then it will be created.
      var model;
      model = new Model();
      model.findEvent('sample:event another:event', true);

    @example Array of names (strings)
      // This will find all events from the names in the given array.
      var model;
      model = new Model();
      model.findEvent(['sample:event', 'another:event']);

    @example Array of names (strings) with build
      // This will find all events from the names in the given array.
      // If event cannot be found then it will be created.
      var model;
      model = new Model();
      model.findEvent(['sample:event', 'another:event'], true);

  ###
  findEvent: (names, build = false) ->
    # Split name into an Array of names if it is a string
    if typeof names is 'string' then names = names.split /\s+/
    # Initiate @__events property if not yet initialised, this avoids having to create a constructor method.
    events = @__events = @__events or {}
    # Iterate through each name returns the found/created events
    for name in names
      # Check if event exists assigning it to event for later use
      if not event = events[name]
        # If we are to build then add a default event structure else continue the iteration
        if build then event = @__events[name] = {name, __callbacks: []}
        else continue
      # Push found/created event into the returning Array
      event

  ###
    Bind a callback to the event system. The callback is invoked when an event is triggered. Events are added to an
    object based on their name. Name spacing is useful to separate events into their relevant types. It is typical to
    use colons for name spacing, Default Tweak events will use the colon character as its name spacing. However you can
    use any other name spacing characters such as / \ - _ or . Please keep in mind that if you vary the name spacing the
    events will be treated as unique.
    
    @overload addEvent(names, callback, context, max)
      Bind a callback to event(s) with context and/or total calls
      @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @param [Function] callback The event callback function.
      @param [Object] context (optional, default = this) The contextual object of which the event to be bound to.
      @param [Number] max (optional, default = null). The maximum calls on the event listener. After the total calls
      the events callback will not invoke.

    @overload addEvent(names, callback, max, context)
      Bind a callback to event(s) with total calls and/or context
      @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @param [Function] callback The event callback function.
      @param [Number] max The maximum calls on the event listener. After the total calls the events callback will not invoke.
      @param [Object] context (optional, default = this) The contextual object of which the event to be bound to.

    @example Bind a callback to event(s)
      var model;
      model = new Model();
      model.addEvent('sample:event', function(){
        alert('Sample event triggered.')
      });
    
    @example Bind a callback to event(s) with total calls
      var model;
      model = new Model();
      model.addEvent('sample:event', function(){
        alert('Sample event triggered.')
      }, 4);

    @example Bind a callback to event(s) with a separate context without total calls
      var model;
      model = new Model();
      model.addEvent('sample:event', function(){
        alert('Sample event triggered.')
      }, this);

    @example Bind a callback to event(s) with a separate context with maximum calls
      var model;
      model = new Model();
      model.addEvent('sample:event', function(){
        alert('Sample event triggered.')
      }, this, 3);
  ###
  addEvent: (names, callback, context = @, max) ->
    # Allows for context and max calls to be reversed
    if typeof context is 'number' or context is null then [max, context] = [context, max]
    # Set max to 0 if null
    max or= 0

    # Find events / build the event path, then iterate through them.
    for event in @findEvent names, true
      # For each iteration set toAdd to true, this determines whether to add or update event callback
      toAdd = true
      # Iterate through all callbacks to this event
      for item in event.__callbacks
        # If the callback and context for an event match then ignore adding the event, but update the current event.
        if item.callback is callback and context is item.context
          # Update events maximum calls property if max value is undefined then leave as original value
          item.max = max ? item.max
          # Reset event calls back to zero
          item.calls = 0
          # Event may listen again ignore adding new callback
          item.listen = not toAdd = false
      # If event was not updated then push callback to event
      if toAdd then event.__callbacks.push {context, callback, max, calls:0, listen:true}
    return

  ###
    Remove a previously bound callback function. Removing events can be limited to context and its callback. This will
    destroy references to the callback event. To stop listening to an event without removing the event use the
    updateEvent method.

    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Function] callback (optional) The callback function of the event. If an event has a matching callback or
    callback argument is null it will be removed, however removing this event will be limited to the context argument.
    @param [Object] context (default = this) The contextual object of which the event is bound to. If an event has a
    matching context or context argument is null it will be removed, however removing this event will be limited to the
    callback argument.

    @example Unbind a callback from event(s)
      var model;
      model = new Model();
      model.removeEvent('sample:event another:event', @callback);

    @example Unbind all callbacks from event(s)
      var model;
      model = new Model();
      model.removeEvent('sample:event another:event');
  ###
  removeEvent: (names, callback, context = @) ->
    # Iterate through found events
    for event in @findEvent names
      # Check to see if the callback and/or context matches.
      # If event matches criteria then delete.
      for key, item of event.__callbacks
        if (not callback? or callback is item.callback) and (not context? or context is item.context)
          event.__callbacks.splice key,1
      # If callbacks is empty then delete from @__events object
      if event.__callbacks.length is 0
        delete @__events[event.name]

    return

  ###
    Trigger event callbacks by name. Triggers can be limited to matching context. When triggering an event you may pass
    as many arguments to the callback method.

    @overload triggerEvent(names, params)
      Trigger events by name only.
      @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @param [...] params Parameters to pass into the callback function.

    @overload triggerEvent(options, params)
      Trigger events by name and context.
      @param [Object] options Options and limiters to check against callbacks.
      @param [...] params Parameters to pass into the callback function.
      @option options [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @option options [Context] context (Default = null) The context of the callback to check against a callback.

    @example Triggering event(s)
      var model;
      model = new Model();
      model.triggerEvent('sample:event, another:event');

    @example Triggering event(s) with parameters
      var model;
      model = new Model();
      model.triggerEvent('sample:event another:event', 'whats my name', 'its...');

    @example Triggering event(s) but only with matching context
      var model;
      model = new Model();
      model.triggerEvent({context:@, name:'sample:event another:event'});
  ###
  triggerEvent: (names, params...) ->
    # If names argument is an object then set names and context
    if typeof names is 'object' and not names instanceof Array then {names, context} = names
    
    # Iterate through found events
    for event in @findEvent names
      # Iterate through this event's callbacks only when item is in a listening state
      for item in event.__callbacks when item.listen
        # If there is a context limit calls to the events with matching context
        if not context? or context is item.context
          # Update the total calls and check if it has hit maximum calls, if it has turn listening state off
          if ++item.calls >= item.max and item.max? then item.listen = false
          # Call the events callback - done asynchronously.
          setTimeout (-> @callback.apply @context, params; return).bind(item), 0
    return

  ###
    Update an event. With this method it is possible to set the events listening state, maximum calls, and total calls
    while limiting updated events by name and optional callback and/or context.
    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Object] options Optional limiters and update values.
    @option options [Object] context The contextual object to limit updating events to, this is a combined limiter, the
    value of the callback option will determine the events to update.
    @option options [Function] callback Callback function to limit updating events to, this is a combined limiter, the
    value of the context option will determine the events to update.
    @option options [Number] max Set a new maximum amount of allowed calls for an event.
    @option options [Number] calls Set the amount of calls that has been triggered on this event.
    @option options [Boolean] reset (Default = false) If true then calls on an event get set back to 0.
    @option options [Boolean] listen Whether to enable or disable listening state of an event.

    @example Updating event(s) to not listen
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {listen:false});

    @example Updating event(s) to not listen, however limited by optional context and/or callback
      // Limit events that match to a context and callback.
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {context:@, callback:@callback, listen:false});

      // Limit events that match to a callback.
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {callback:@anotherCallback, listen:false});

      // Limit events that match to a context.
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {context:@, listen:false});

    @example Updating event(s) maximum calls and reset its current calls
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {reset:true, max:100});

    @example Updating event(s) total calls
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {calls:29});
  ###
  updateEvent: (names, options = {}) ->
    # Set limiters and update properties
    {context, max, reset, calls, listen, callback} = options
    # If reset is true then set calls to 0
    if reset then calls = 0

    # Iterate through found events
    for event in @findEvent names
      # Iterate through this event's callbacks
      for item in event.__callbacks
        # Check to see if the callback and/or context matches.
        if (not context? or context isnt item.context) and (not callback? or callback isnt item.callback)
          # Update event properties
          if max? then item.max = max
          if calls? then item.calls = calls
          if listen? then item.listen = listen
    return

  ###
    Resets the events on this object to empty.
  ###
  resetEvents: -> @__events = {}
