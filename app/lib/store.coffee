###
  This is the base Object for dynamic storage based modules. This will contain the core functionality for these type of functions
  A collection is where data can be stored. A collection is an array storage based system. A model is an object storage based system.

  The store is simply a way of storing some data, with event triggering on changes to the store.
  In common MVC concept the store is not always a database. Therefore a store in TweakJS is a temporary storage of data. So the controller should be used to get/set data from/to a database.
  The controller is normally the interface between the view and the stores data.
  When the store updates it will fire of events to Event system; allowing you to listen to what has been changed. The controller can then detirmine what to do when it gets updated.
  You can update the store quietly aswell.
###
class tweak.Store

  # @property [Object] The config object of this module
  config: {}
  # @property [Integer] Length of the stores data
  length: 0
  # @property [Object, Array] Data holder for the store
  data: []
  # @property [String] The type of storage, ie 'collection' or 'model'
  storeType: 'BASE'
  # @property [Integer] The uid of this object - for unique reference
  uid: 0
  # @property [Integer] The component uid of this object - for unique reference of component
  cuid: 0
  # @property [Component] The root component
  root: null

  __triger: tweak.Common.__trigger

  # @private
  constructor: ->
    # Set uid
    @uid = "s_#{tweak.uids.s++}"

  ###
    Set multiple properties or one property of the store by passing an object with object of the data you with to update.

    @overload set(name, data, quiet)
      Set an individual property in the store by name
      @param [String] name The name of the property to set
      @param [*] data Data to store in the property
      @param [Boolean] quiet Setting to trigger change events

    @overload set(properties, quiet)
      Set an multiple properties in the store from an object
      @param [Object] properties Key and property based object to store into store
      @param [Boolean] quiet Setting to trigger change events

    @event #{@name}:#{@storeType}:changed:#{key} Triggers an event and passes in changed property
    @event #{@component.uid}:#{@storeType}:changed:#{key} Triggers an event and passes in changed property
    @event #{@uid}:changed:#{key} Triggers an event and passes in changed property

    @event #{@name}:#{@storeType}:changed Triggers a generic event that the store has been updated
    @event #{@component.uid}:#{@storeType}:changed Triggers a generic event that the store has been updated
    @event #{@uid}:changed Triggers a generic event that the store has been updated
  ###
  set: (properties, params...) ->
    quiet = params[0]
    if typeof properties is 'string'
      prevProps = properties
      properties = {}
      properties[prevProps] = params[0]
      quiet = params[1]
    for key, prop of properties
      prev = @data[key]
      if not prev? then @length++
      @data[key] = prop
      
      if not quiet then @__trigger "#{@storeType}:changed:#{key}", prop

    if not quiet then @__trigger "#{@storeType}:changed"
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
    Remove an element at a given position
    @param [Integer] position Position of property to return
    @param [Boolean] quiet Setting to trigger change events

  ###
  removeAt: (position, quiet) ->
    element = @at position
    removed = null
    for key, prop of element
      @remove key, quiet
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