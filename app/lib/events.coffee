### 
  ----- Events System -----
  The framework is driven by a powerful and simple event system. 

  The event system simply stores the callbacks in an object tree.
  The tree allows quick traversal of events, during interaction with the event API

  Listed functions:
    on
    off
    trigger
    find
    reset

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
  constructor: -> @reset()

  ###
    Description:  
      Add an event listener into the event system. 
      The event system will store the object based on its event name
      The event name is split on the / and : characters

    Parameters:   name:String, callback:Function, maxCalls:Number

    Examples: 
      // Sample event
      tweak.Events.on(this, "sample/event", function(){
        alert("Sample event triggered.")
      })

      // Sample event with a maximum amount of calls
      // This example will allow the event to be called twice
      // The event is automatically removed from the event object on max calls
      tweak.Events.on(this, "sample/event", function(){
        alert("Sample event triggered.")
      }, 2)        
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
    Description:  
      Remove from events by given name
      If no specific function is given then all the events under node are removed
    Parameters: context, name:String, callback:Function  
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
    Description:  
      Trigger events by name
      Also pass params to event
    Parameters:  name:String or Object ({name:String, context}), [params] 
    Returns: 
      Returned values of the callbacks
      False if no callbacks or event found     
  ###   
  trigger: (name, params...) ->
    if typeof name is "object"
      context = name.context
      name = name.name or name.event or ""

    console.log name
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
    Description: 
      Iterate through the events to find given event

    Parameters: name:String, build:Boolean = false
    Returns: Event or Null
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
    Description: Resets the events back to empty.  
  ###
  reset: -> @events = {}; return

### Initialise EventSystem ###
tweak.Events = new tweak.EventSystem()
