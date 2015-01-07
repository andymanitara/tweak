###
  The model is simply a way of storing some data, with event triggering on changes to the model
  In common MVC concept the Model is not always a database. So the controller should be used to get data from a database.
  The controller is normally the interface between the view and the models data.
  When the model updates it will fire of events to Event system; allowing you to listen to what has been changed. The controller can then detirmine what to do when it gets updated.
  You can update the model quietly aswell.
###
class tweak.Model extends tweak.Store
  # Not using own tweak.extends method as codo doesnt detect that this is an extending class

  # @property [Object] Data storage holder, for a model this is an object
  data: {}
  # @property [String] The type of collection this is
  storeType: "model"

  # @private
  constructor: (relation, @data = {}) ->
    @relation = relation ?= {}
    # Set uid
    @uid = "m_#{tweak.uids.m++}"
    @root = relation.root or @
    @name = relation.name

  ###
    Remove a single property or many properties.
    @param [String, Array<String>] properties Array of property names to remove from model, or single String of the name of the property to remove
    @param [Boolean] quiet Setting to trigger change events

    @event #{@name}:model:removed:#{key} Triggers an event based on what property has been removed
    @event #{@component.uid}:model:removed:#{key} Triggers an event based on what property has been removed
    @event #{@uid}:removed:#{key} Triggers an event based on what property has been removed

    @event #{@name}:model:changed Triggers a generic event that the model has been updated
    @event #{@component.uid}:model:changed Triggers a generic event that the model has been updated
    @event #{@uid}:model:changed Triggers a generic event that the model has been updated
  ###
  remove: (properties, quiet = true) ->
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      for key, prop of data when key is property
        @length--
        delete @data[key]
        if not quiet then tweak.Common.__trigger @, "#{@storeType}:removed:#{key}"

    if not quiet then tweak.Common.__trigger @, "#{@storeType}:changed"
    return

  ###
    Get an element at position of a given number
    @param [Integer] position Position of property to return
    @return [*] Returns data of property by given position
  ###
  at: (position) ->
    position = Number position
    data = @data
    i = 0
    for key, prop of data
      if i is position then return data[key]
      i++

    null

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
    Reset the model back to defaults
  ###
  reset: ->
    @data = {}

  ###
    Import a JSONObject.
    @param [JSONString] data JSONString to parse.
    @param [Object] options Options to parse to method.
    @option options [Array<String>] restrict Restrict which properties to convert. Default: all properties get converted.
    @option options [Boolean] quiet If true then it wont trigger events
    @return [Object] Returns the parsed JSONString as a raw object
  ###
  import: (data, options = {}) -> @set @parse(data, options.restict), options.quiet or true

  ###
    Export a JSONString of this models data.
    @param [Array<String>] restrict Restrict which properties to convert. Default: all properties get converted.
    @return [Object] Returns a JSONString
  ###
  export: (restrict) -> @parse @data, restrict
