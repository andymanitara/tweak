###
  The model is simply a way of storing some data, with event triggering on changes to the model
  In common MVC concept the Model is not always a database. So the controller should be used to get data from a database.
  The controller is normally the interface between the view and the models data.
  When the model updates it will fire of events to Event system; allowing you to listen to what has been changed. The controller can then detirmine what to do when it gets updated.
  You can update the model quietly aswell.
  The model has its own history, so you can easily revert.
###
class tweak.Model
  # @property [Integer] Length of the models data
  length: 0
  # @property [Object] Data in the model
  data: {}
  # @property [Array] History of the model data
  history: []
  # @property [Object] Default data to load into model when constructing the model
  default: {}
  
  tweak.Extend(@, ['trigger', 'on', 'off', 'clone', 'reduced', 'same', 'init'], tweak.Common)

  ###
    Constructs the model ready for use
  ###
  construct: ->
    @reset()
    # Defaults are overriden completely when overriden by an extending model, however config model data is merged
    if @defaults? then @set @defaults, {quiet:true, store:false}
    data = @config or {}
    if data then @set data, {quiet:true, store:false}
  
  ###
    Returns if the model has a certain property
    @param [String] property Property name to look for in model data
    @return [Boolean] Returns true or false depending if the property exists in the model
  ###
  has: (property) -> @data[property]?
  
  ###
    Returns a models property value
    @param [String] property Property name to look for in model data
    @return [*] Returns property value of property in model
  ###
  get: (property) -> @data[property]
  
  ###
    Set multiple properties or one property of the model by passing an object with object of the data you with to update.

    @overload set(name, data, options)
      Set an individual property in the model by name
      @param [String] name The name of the property to set
      @param [*] data Data to store in the property
      @param [Object] options Options to detirmine extra functionality
      @option options [Boolean] store Decide whether to store the change to the history. Default: true
      @option options [Boolean] quiet Decide whether to trigger model changed events. Default: false

    @overload set(properties, options)
      Set an multiple properties in the model from an object
      @param [Object] properties Key and property based object to store into model
      @param [Object] options Options to detirmine extra functionality
      @option options [Boolean] store Decide whether to store the change to the history. Default: true
      @option options [Boolean] quiet Decide whether to trigger model changed events. Default: false

    @event #{@name}:model:changed:#{key} Triggers an event and passes in changed property
    @event #{@name}:model:changed Triggers a generic event that the model has been updated
  ###
  set: (properties, params...) ->
    options = params[0]
    if typeof properties is 'string'
      prevProps = properties
      properties = {}
      properties[prevProps] = params[0]
      options = params[1]
    options or= {}
    store = if options.store? then options.store else true
    quiet = options.quiet
    if store then @store()
    for key, prop of properties
      @data[key] = prop
      @length++
      if not quiet then @trigger "#{@name}:model:changed:#{key}", prop

    if not quiet then @trigger "#{@name}:model:changed"

    return

  ###
    Remove a single property or many properties.
    @param [String, Array<String>] properties Array of property names to remove from model, or single String of the name of the property to remove
    @param [Object] options Options to detirmine extra functionality
    @option options [Boolean] store Decide whether to store the change to the history. Default: true
    @option options [Boolean] quiet Decide whether to trigger model events. Default: false

    @event #{@name}:model:removed:#{key} Triggers an event based on what property has been removed
    @event #{@name}:model:changed Triggers a generic event that the model has been updated
  ###
  remove: (properties, options = {}) ->
    store = if options.store? then true else false
    quiet = options.quiet
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      for key, prop of data
        if key is property
          @length--
          delete @data[key]
          @trigger "#{@name}:model:removed:#{key}"
    
    if store then @store()
    if not quiet then @trigger "#{@name}:model:changed"
    return
  
  ###
    Revert the model back to previous state in history, default is one previous version.
    @overload revert(amount, options)
      Revert the model data by specified amount of states with options provided
      @param [Integer] amount The amount of states in the history to revert back by
      @param [Object] options Options to detirmine extra functionality
      @option options [Boolean] store Decide whether to store the change to the history. Default: true
      @option options [Boolean] quiet Decide whether to trigger model events. Default: false

    @overload revert(options)
      Revert the data by one with options provided
      @param [Object] options Options to detirmine extra functionality
      @option options [Boolean] store Decide whether to store the change to the history. Default: true
      @option options [Boolean] quiet Decide whether to trigger model events. Default: false

    @event - Events triggered from set method functionality if quiet option is false
  ###
  revert: (params...) ->
    if typeof params[0] is 'object' then options = params[0]
    else
      amount = params[0]
      options = params[1]
    options or= {}
    amount ?= 1
    history = @history
    historyLength = history.length
    if amount > historyLength then amount = historyLength
    state = history[historyLength - amount]
    @data = {}
    @set @clone(state), options
    return
  
  ###
     Returns the changed properties between the current model and a previous model state. Default is one state behind.
     @param [Integer] position the amount of stated behind to compare to. Default: 1
     @return [Object] Returns the changed properties and there values in an Object
  ###
  changed: (position) ->
    position ?= 1
    if position > @history.length then position = @history.length
    state = @history[@history.length - position]
    data = @data
    results = {}
    for key, prop of data
      if not state[key]? then results[key] = prop
      for prevKey, prevProp of state
        if not data[prevKey]? then results[prevKey] = prevProp
        if key is prevKey
          if prop isnt prevProp then results[key] = prevProp
    results
  
  ###
    Store the models data to the history
  ###
  store: ->
    @history.push(@clone @data)
    memLength = @relation.memoryLength
    history = @history
    historyLength = history.length
    if memLength? and memLength < historyLength then @reduced(memLength)
    return
  
  ###
    Reset the model back to defaults
  ###
  reset: ->
    @data = {}
    @history = []
    return

  ###
    Get an element at position of a given number
    @param [Integer] position Position of property to return
    @return [*] Returns data of property by given position
  ###
  at: (position) ->
    position = Number(position)
    data = @data
    i = 0
    for key, prop of data
      if i is position then return data[key]
      i++

    null
  
  ###
    Remove an element at a given position
    @param [Integer] position Position of property to return
    @param [Object] options Options to detirmine extra functionality
    @option options [Boolean] store Decide whether to store the change to the history. Default: true
    @option options [Boolean] quiet Decide whether to trigger model events. Default: false
  ###
  removeAt: (position, options = {}) ->
    element = @at position
    for key, prop of element
      @remove key, options
    return
  
  ###
    Returns an array of property names where the value is equal to the given value
    @param [*] value Value to check
    @return [Array<String>] Returns an array of property names where the value is equal to the given value
  ###
  where: (value) ->
    result = []
    data = @data
    for key, prop of data
      if prop is value then result.push key
    return result