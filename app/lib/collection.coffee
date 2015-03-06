###
  A Collection is used by other modules like the Controller to store, retrieve and listen to a set of
  ordered data. A Collection triggers events when it's storage base is updated, this makes it easy to
  listen to changes and to action as and when required. The Collection data is not a database, but a JSON
  representation of its data can be exported and imported to and from storage sources. In Tweak.js the Model
  extends the Store module - which is the core functionality shared between Model's and Collection's. The
  main difference between a Model and collection it the base of its data type. The Model uses an object as
  its base data type and a collection base type is an Array.

  To further extend a Collection, Tweak.js allows data to be imported and exported. When doing this please
  know that all data stored should be able to be converted to a JSON string. A Collection of Models can
  also be exported and imported to and from a database, as it has an inbuilt detection for when a value
  should be created as a Model representation. Keep note that a Collection of Collections is not
  appropriate as this becomes complicated and it can get messy quickly. It should be possible to export and
  import data of that nature, but it’s not recommended - always try to keep stored data structured simply.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples are not exact, and will not
  directly represent valid code; the aim of an example is to show how to roughly use a method.
###
class tweak.Collection extends tweak.Store
  # @property [String] The type of storage, i.e. 'collection' or 'model'
  _type: "collection"

  ###
    The constructor initialises the controllers unique ID and its initial data.
    @example Creating a Collection with predefined set of data
      var collection;
      collection = new tweak.Collection({
        "demo":true,
        "example":false,
        "position":99
      });
  ###
  constructor: (@data = []) -> @uid = "cl_#{tweak.uids.cl++}"

  ###
    Reduce an array be remove elements from the front of the array and returning the new array
    @param [Array] arr Array to reduce
    @param [Number] length The length that the array should be
    @return [Array] Returns reduced array
  ###
  reduced: (arr, length) ->
    start = arr.length - length
    for [start..length] then arr[_i]
    
  ###
    Pop the top data element in the collection
    @param [Boolean] silent (optional) (default = false) Silently change the base storage property, by not triggering events upon change

    @event removed:#{key} Triggers an event based on what property has been removed
    @event changed Triggers a generic event that the collection has been updated
    @return [*] Returns the data that was removed
  ###
  pop: (silent) ->
    result = @data[@length-1]
    @remove result, silent
    result
  
  ###
    Add a new property to the end of the collection
    @param [*] data Data to add to the end of the collection
    @param [Boolean] silent (optional) (default = false) Silently change the base storage property, by not triggering events upon change

    @event changed:#{key} Triggers an event and passes in changed property
    @event changed Triggers a generic event that the collection has been updated
  ###
  add: (data, silent) ->
    @set "#{@length}", data, silent
    return
  
  ###
    Inserts a new property into a certain position
    @param [*] data Data to insert into the collection
    @param [Number] position The position to insert the property at into the collection
    @param [Boolean] silent (optional) (default = false) Silently change the base storage property, by not triggering events upon change

    @event changed:#{key} Triggers an event and passes in changed property
    @event changed Triggers a generic event that the collection has been updated
  ###
  place: (data, position, silent) ->
    result = []
    for prop in @data
      if position is _i then break
      result.push @data[_i]
    result.push data
    for data in @data
      if _j < position then continue
      result.push @data[_j]
    @data = result
    if not silent
      @triggerEvent "changed changed:#{position}"
    return
  
  ###
    Looks through the collection for where the data matches.
    @param [*] property The property data to find a match against.
    @return [Array] Returns an array of the positions of the data.
  ###
  pluck: (property) ->
    for key, prop of @data
      if prop is property then key

  ###
    Remove a single property or many properties.
    @param [String, Array<String>] properties Array of property names to remove from collection, or single String of the name of the property to remove
    @param [Boolean] silent (optional) (default = false) Silently change the base storage property, by not triggering events upon change

    @event removed:#{key} Triggers an event based on what property has been removed
    @event changed Triggers a generic event that the collection has been updated
  ###
  remove: (properties, silent) ->
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      @data.splice property, 1
      if not silent then @triggerEvent "removed:#{property}"
    if not silent then @triggerEvent "changed"
    return

  ###
    Get an element at position of a given number
    @param [Integer] position Position of property to return
    @param [Boolean] silent (optional) (default = false) Silently change the base storage property, by not triggering events upon change
    @return [*] Returns data of property by given position
  ###
  at: (position) -> @data[Number position]

  ###
    Remove an element at a given position
    @param [Integer] position Position of property to return
    @param [Boolean] silent (optional) (default = false) Silently change the base storage property, by not triggering events upon change
    
    @example removing a property at a given index
      this.removeAt(1);

    @example removing a property at a given index silently
      this.removeAt(3, true);
  ###
  removeAt: (position, silent) ->
    element = @at position
    for key, prop of element
      @remove key, silent
    return

  ###
    Reset the collection back to defaults
    
    @event changed Triggers a generic event that the store has been updated
  ###
  reset: ->
    @data = []
    super()
    return
  
  ###
    Import a JSONObject - imports to one depth only.
    @param [JSONString] data JSONString to parse.
    @param [Object] options Options to parse to method.
    @option options [Array<String>] limit Limit which properties to convert. Default: all properties get converted.
    @option options [Boolean] overwrite Default:true. If true existing properties in the key value will be replaced otherwise they are added to the collection
    @option options [Boolean] silent If true then it wont trigger events
    @return [Object] Returns the parsed JSONString as a raw object
  ###
  import: (data, options = {}) ->
    data = @parse data, options.limit
    overwrite = options.overwrite ?= true
    for key, item of data
      prop = if item.type
        new tweak[item.type] @, item.data
      else item
      if not overwrite and @data[key]
        @set {key:prop}, options.silent
      else @data.add prop, options.silent
    data

  ###
    Export a JSONString of this collections data.
    @param [Array<String>] limit Limit which properties to convert. Default: all properties get converted.
    @return [Object] Returns a JSONString
  ###
  export: (restrict) ->
    res = {}
    for key, item of @data
      res[key] = if item._type
        {type:item._type, data:@parse item.export()}
      else item
    @parse res, limit