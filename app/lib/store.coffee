###
  This is the base Object for dynamic storage based modules. This will contain the core functionality for these type of functions
  A collection is where data can be stored. A collection is an array storage based system. A model is an object storage based system.

  The store is simply a way of storing some data, with event triggering on changes to the store
  In common MVC concept the store is not always a database. So the controller should be used to get data from a database.
  The controller is normally the interface between the view and the stores data.
  When the store updates it will fire of events to Event system; allowing you to listen to what has been changed. The controller can then detirmine what to do when it gets updated.
  You can update the store quietly aswell.
  The store has its own history, so you can easily revert.

  @todo Update pluck to use new same functionality
  @include tweak.Common.Empty
  @include tweak.Common.Events
  @include tweak.Common.Collections
###
class tweak.Store

  # @property [Object] The config object of this module
  config: {}
  # @property [Integer] Length of the stores data
  length: 0
  # @property [Object, Array] Data holder for the store
  data: []
  # @property [Array] History of the data store
  history: []
  # @property [String] The type of storage, ie 'collection' or 'model'
  storeType: 'BASE'

  tweak.Extend @, [
    tweak.Common.Empty
    tweak.Common.Events
    tweak.Common.Collections
  ]

  ###
    Set multiple properties or one property of the store by passing an object with object of the data you with to update.

    @overload set(name, data, options)
      Set an individual property in the store by name
      @param [String] name The name of the property to set
      @param [*] data Data to store in the property
      @param [Object] options Options to detirmine extra functionality
      @option options [Boolean] store Decide whether to store the change to the history. Default: true
      @option options [Boolean] quiet Decide whether to trigger store changed events. Default: false

    @overload set(properties, options)
      Set an multiple properties in the store from an object
      @param [Object] properties Key and property based object to store into store
      @param [Object] options Options to detirmine extra functionality
      @option options [Boolean] store Decide whether to store the change to the history. Default: true
      @option options [Boolean] quiet Decide whether to trigger store changed events. Default: false

    @event #{@name}:#{@storeType}:changed:#{key} Triggers an event and passes in changed property
    @event #{@name}:#{@storeType}:changed Triggers a generic event that the store has been updated
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
      if not quiet then @trigger "#{@name}:#{@storeType}:changed:#{key}", prop, options

    if not quiet then @trigger "#{@name}:#{@storeType}:changed"

    return

  ###
    Returns a stores property value
    @param [String] property Property name to look for in store data
    @return [*] Returns property value of property in store
  ###
  get: (property) -> @data[property]

  ###
    Returns if the store has a certain property
    @param [String] property Property name to look for in store data
    @return [Boolean] Returns true or false depending if the property exists in the store
  ###
  has: (property) -> @data[property]?

  ###
    Looks through the store for where the data matches.
    @param [*] property The property data to find a match against.
    @return [Array] Returns an array of the positions of the data.
  ###
  pluck: (property) ->
    result = []
    for key, prop of @data
      if prop is property then result.push key
    result

  ###
    Store the data to the history
  ###
  store: ->
    @history.push(@clone @data)
    memLength = @relation.memoryLength
    history = @history
    historyLength = history.length
    if memLength? and memLength < historyLength then @reduced(memLength)
    return
  
  ###
    Remove an element at a given position
    @param [Integer] position Position of property to return
    @param [Object] options Options to detirmine extra functionality
    @option options [Boolean] store Decide whether to store the change to the history. Default: true
    @option options [Boolean] quiet Decide whether to trigger store events. Default: false
  ###
  removeAt: (position, options = {}) ->
    element = @at position
    removed = null
    for key, prop of element
      @remove key, options
    return

  ###
     Returns the changed properties between the current store and a previous store state. Default is one state behind.
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
    Revert the store back to previous state in history, default is one previous version.
    @overload revert(amount, options)
      Revert the store data by specified amount of states with options provided
      @param [Integer] amount The amount of states in the history to revert back by
      @param [Object] options Options to detirmine extra functionality
      @option options [Boolean] store Decide whether to store the change to the history. Default: true
      @option options [Boolean] quiet Decide whether to trigger store events. Default: false

    @overload revert(options)
      Revert the data by one with options provided
      @param [Object] options Options to detirmine extra functionality
      @option options [Boolean] store Decide whether to store the change to the history. Default: true
      @option options [Boolean] quiet Decide whether to trigger store events. Default: false

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