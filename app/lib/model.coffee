###
  A Model is used by other modules like the Controller to store, retrieve and
  listen to a set of data. Tweak.js will call events through its
  **event system** when it is updated, this makes it easy to listen to updates and
  to action as and when required. The Model’s data is not a database, but a JSON
  representation of its data can be exported and imported to and from storage
  sources. In Tweak.js the Model extends the Store module - which is the core
  functionality shared between the Model and Collection. The main difference
  between a Model and collection it the base of its storage. The Model uses an
  object to store its data and a collection base storage is an Array.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an
  example is to show how to roughly use a method.
###
class tweak.Model extends tweak.Store
  # @property [Object] Data storage holder, for a model this is an object.
  data: {}
  # @property [String] The type of Store, i.e. 'collection' or 'model'.
  _type: "model"

  ###
    The constructor initialises the controllers unique ID and its initial data.

    @example Creating a Model with predefined set of data
      var model;
      model = new tweak.Model({
        "demo":true,
        "example":false,
        "position":99
      });
  ###
  constructor: (@data = {}) -> @uid = "m_#{tweak.uids.m++}"

  ###
    Remove a single property or many properties.
    @param [String, Array<String>] properties Array of property names to remove from a Model, or single String of the name of the property to remove.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event removed:#{key} Triggers an event based on what property has been removed.
    @event changed Triggers a generic event that the Model has been updated.

    @example Removing a single property.
      var model;
      model = new tweak.Model();
      model.remove("demo");

    @example Removing multiple properties.
      var model;
      model = new tweak.Model();
      model.remove(["demo", "example"]);

    @example Removing properties silently.
      var model;
      model = new tweak.Model();
      model.remove(["demo", "example"], true);
      model.remove("position", true);
  ###
  remove: (properties, silent) ->
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      for key, prop of data when key is property
        @length--
        delete @data[key]
        if not silent then @triggerEvent "removed:#{key}"

    if not silent then @triggerEvent "changed"
    return

  ###
    Get an element at position of a given number.
    @param [Number] position Position of property to return.
    @return [*] Returns data of property by given position.
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
    Import a JSONObject.
    @param [JSONString] data JSONString to parse.
    @param [Object] options Options to parse to method.
    @option options [Array<String>] limit (default = all properties) Limit which properties to convert.
    @option options [Boolean] overwrite (default = true). If true existing properties will be replaced otherwise they are added to the Model.
    @option options [Boolean] silent (default = false) If true events are not triggered upon any changes.

    @example Importing a JSONObject to a Model
      // This is a simple demo with a JSONString being passed
      var model;
      model = new tweak.Model();
      model.import("{'demo':'example'}");

    @example Importing a JSONObject to a model silently
      // This is a simple demo with a JSONString being passed
      var model;
      model = new tweak.Model();
      model.import("{'demo':'example'}", {
        silent:true
      });

    @example Importing a JSONObject to a Model but with restrictions to what should be imported
      // This is a simple demo with a JSONString being passed with only demo value being updated
      var model;
      model = new tweak.Model();
      model.import("{'demo':'example', 'simon':'pegg'}", {
        limit:["demo"]
      });
  ###
  import: (data, options = {}) -> 
    @set @parse(data, options.limit), options.silent or true
    return

  ###
    Export the Model as a JSONString.
    @param [Array<String>] limit (default = all properties) Limit which properties to convert.
    @return [Object] Model as a JSONString

    @example Exporting all data from this Model as a JSONObject
      var model, jsonString;
      model = new tweak.Model();
      jsonString = model.export();

    @example Exporting limited data from this Model as a JSONObject
      var model, jsonString;
      model = new tweak.Model();
      jsonString = model.export([
        'position',
        'demo'
      ]);
  ###
  export: (restrict) -> @parse @data, restrict

  ###
    Reset the Model back to defaults.
    @event changed Triggers a generic event that the Model has been updated.
  ###
  reset: ->
    @data = {}
    super()
    return