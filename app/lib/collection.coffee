###
  A collection is where data can be stored, a default collection is an array based system. The model is a extension to the default collection; but based on an object.
###
class tweak.Collection extends tweak.Store
  # @property [String] The type of storage, ie 'collection' or 'model'
  storeType: "collection"

  # @private
  constructor: (@relation, @config = {}) ->
    # Set uid
    @uid = "cl_#{tweak.uids.cl++}"
    @root = relation.root or @
    @name = config.name or relation.name
    @reset()

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
    Removes empty keys
  ###
  clean: -> @data = for key, item of @data then item
    
  ###
    Pop the top data element in the collection
    @param [Boolean] quiet Setting to trigger change events

    @event #{@name}:#{@storeType}:removed:#{key} Triggers an event based on what property has been removed
    @event #{@name}:#{@storeType}:changed Triggers a generic event that the collection has been updated
    @return [*] Returns the data that was removed
  ###
  pop: (quiet) ->
    result = @data[@length-1]
    @remove result, quiet
    result
  
  ###
    Add a new property to the end of the collection
    @param [*] data Data to add to the end of the collection
    @param [Boolean] quiet Setting to trigger change events

    @event #{@name}:#{@storeType}:changed:#{key} Triggers an event and passes in changed property
    @event #{@name}:#{@storeType}:changed Triggers a generic event that the collection has been updated
  ###
  add: (data, quiet) -> @set "#{@length}", data, quiet
  
  ###
    Inserts a new property into a certain position
    @param [*] data Data to insert into the collection
    @param [Number] position The position to insert the property at into the collection
    @param [Boolean] quiet Setting to trigger change events

    @event #{@name}:#{@storeType}:changed:#{key} Triggers an event and passes in changed property
    @event #{@component.uid}:#{@storeType}:changed:#{key} Triggers an event and passes in changed property
    @event #{@uid}:changed:#{key} Triggers an event and passes in changed property

    @event #{@name}:#{@storeType}:changed Triggers a generic event that the collection has been updated
    @event #{@component.uid}:#{@storeType}:changed Triggers a generic event that the collection has been updated
    @event #{@uid}:changed Triggers a generic event that the collection has been updated
  ###
  place: (data, position, quiet) ->
    result = []
    for prop in @data
      if position is _i then break
      result.push @data[_i]
    result.push data
    for data in @data
      if _j < position then continue
      result.push @data[_j]
    @data = result
    if not quiet
      tweak.Common.__trigger "#{@storeType}:changed"
      tweak.Common.__trigger "#{@storeType}:changed:#{position}"
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
    @param [Boolean] quiet Setting to trigger change events

    @event #{@name}:#{@storeType}:removed:#{key} Triggers an event based on what property has been removed
    @event #{@component.uid}:#{@storeType}:removed:#{key} Triggers an event based on what property has been removed
    @event #{@uid}:removed:#{key} Triggers an event based on what property has been removed

    @event #{@name}:#{@storeType}:changed Triggers a generic event that the collection has been updated
    @event #{@component.uid}:#{@storeType}:changed Triggers a generic event that the collection has been updated
    @event #{@uid}:changed Triggers a generic event that the collection has been updated
  ###
  remove: (properties, quiet) ->
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      delete @data[property]
      tweak.Common.__trigger "#{@storeType}:removed:#{property}"
    
    @clean()
    if not quiet then tweak.Common.__trigger "#{@storeType}:changed"
    return

  ###
    Get an element at position of a given number
    @param [Integer] position Position of property to return
    @return [*] Returns data of property by given position
  ###
  at: (position) -> @data[Number(position)]

  ###
    Reset the collection back to defaults
  ###
  reset: ->
    @data = []
    @length = 0
  
  ###
    Import a JSONObject - imports to one depth only.
    @param [JSONString] data JSONString to parse.
    @param [Object] options Options to parse to method.
    @option options [Array<String>] restrict Restrict which properties to convert. Default: all properties get converted.
    @option options [Boolean] overwrite Default:true. If true existing properties in the key value will be replaced otherwise they are added to the collection
    @option options [Boolean] quiet If true then it wont trigger events
    @return [Object] Returns the parsed JSONString as a raw object
  ###
  import: (data, options = {}) ->
    data = @parse data, options.restict
    overwrite = options.overwrite ?= true
    for key, item of data
      prop = if item.type
        new tweak[item.type](@, item.data)
      else item
      if not overwrite and @data[key]
        @set {key:prop}, options.quiet
      else @data.add prop, options.quiet
    data

  ###
    Export a JSONString of this collections data.
    @param [Array<String>] restrict Restrict which properties to convert. Default: all properties get converted.
    @return [Object] Returns a JSONString
  ###
  export: (restrict) ->
    res = {}
    for key, item of @data
      res[key] = if item.storeType
        {type:item.storeType, data:@parse item.export()}
      else item
    @parse res, restict