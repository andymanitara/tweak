###
  A Model is used by other modules like the Controller to store, retrieve and listen
  to a set of data. Tweak.js will call events through its **event system** when it
  is updated, this makes it easy to listen to updates and to action as and when 
  required. The Model’s data is not a database, but a JSON representation of its 
  data can be exported and imported to and from storage sources. In Tweak.js the 
  Model extends the Store module - which is the core functionality shared between 
  the Model and Collection. The main difference between a Model and collection it
  the base of its storage. The Model uses an object to store its data and a 
  collection base storage is an Array.
###
class tweak.Model extends tweak.Store

  # @property [Object] Data storage holder, for a model this is an object
  data: {}
  # @property [String] The type of collection this is
  _type: "model"
  # @property [tweak.EventSystem] An event system is attached to  
  events: {}

  ###
    The constructor initialises the controllers unique ID, contextual relation, its root context, and its initial data. 
    
    @param [Object] relation The contextual object, usually it is the context of where this module is called.
  ###
  constructor: (relation, @data = {}) ->
    # Set uid
    @uid = "m_#{tweak.uids.m++}"
    # Set the relation to this object, if no relation then set it to a blank object. 
    @relation = relation ?= {}
    # Set the root relation to this object, this will look at its relations root.
    # If there is no root relation then this becomes the root relation to other modules. 
    @root = relation.root or @

  ###
    Remove a single property or many properties.
    @param [String, Array<String>] properties Array of property names to remove from model, or single String of the name of the property to remove
    @param [Boolean] quiet Setting to trigger change events

    @event removed:#{key} Triggers an event based on what property has been removed
    @event changed Triggers a generic event that the model has been updated
  ###
  remove: (properties, quiet = true) ->
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      for key, prop of data when key is property
        @length--
        delete @data[key]
        if not quiet then @triggerEvent "removed:#{key}"

    if not quiet then @triggerEvent "changed"
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
    @length = 0
    return

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
