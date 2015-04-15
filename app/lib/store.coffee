###
  This is the base Class for dynamic storage based modules. A good way to think of
  a Store/Model/Collection is to think it as Cache; it can be used to Store data for
  temporary access. It receives and sends its data to a secondary permanent storage
  solution. The Store class is the base functionality shared between a Model and
  Collection. Classes that inherit Store class trigger events when it's storage
  base is updated, this makes it easy to listen to changes and to action as and
  when required.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
###
class tweak.Store extends tweak.Events

  # @property [String] The type of storage, i.e. 'collection' or 'model'
  _type: 'BASE'
  # @property [Integer] Length of the Stores data
  length: 0
  # @property [Object, Array] Data holder for the Store
  data: []
  # @property [Integer] The UID of this object - for unique reference
  uid: 0
  # @property [Method] see tweak.Common.parse
  parse: tweak.Common.parse
  # @property [Method] see tweak.super
  super: tweak.super

  ###
    The constructor initialises the controllers unique ID.
  ###
  constructor: -> @uid = "s_#{tweak.uids.s++}"

  ###
    Default initialiser function
  ###
  init: ->
    
  ###
    Set a single property or multiple properties.

    @overload set(name, data, silent)
      Set an individual property by the name (String).
      @param [String] name The name of the property.
      @param [*] data Data to Store in the property.
      @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes to the data.

    @overload set(data, silent)
      Set multiple properties by an object of data.
      @param [Object] data Key and property based object.
      @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes to the data.

    @example Setting single property.
      this.set("sample", 100);

    @example Setting multiple properties.
      this.set({sample:100, second:2});
  
    @example Setting properties silently.
      this.set("sample", 100, true);
      this.set({sample:100, second:2}, true);

    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Store has been updated.
  ###
  set: (data, params...) ->
    silent = params[0]
    type = typeof data
    if type is 'string' or type is 'number'
      prevProps = data
      data = {}
      data[prevProps] = params[0]
      silent = params[1]

    obj = {}
    for key, prop of data
      prev = @data[key]
      if not prev? then @length++
      @data[key] = @["__set#{key.replace /^[a-z]/, (m) -> m.toUpperCase()}"]?(prop) or prop
      if not silent then @triggerEvent "changed:#{key}", prop

    if not silent then @triggerEvent "changed"
    return

  ###
    Returns whether two objects are the same (similar).
    @param [Object, Array] one Object to compare to Object two.
    @param [Object, Array] two Object to compare to Object one.
    @return [Boolean] Are the two Objects the same/similar?

    @example comparing objects.
      this.same({"sample":true},{"sample":true}); //true
      this.same({"sample":true},{"not":true}); //false
  ###
  same: (one, two) ->
    for key, prop of one
      if not two[key]? or two[key] isnt prop then return false
    true
    
  ###
    Get a property from the base storage.
    @param [String, Array<String>] property Property/properties to retrieve from the base storage.
    @param [...] params Parameters to pass into getter method
    @return [*] Property/properties from base storage.
    
    @overload get()
      Get all properties from base storage.
      @return [Array<*>, Object] Properties from base storage.

    @overload get(name)
      Get an individual property by a property name.
      @param [String] name The name of the property.
      @return [*] Property from base storage.

    @overload get(limit)
      Get multiple properties from base storage.
      @param [Array<String>] limit Array of property names to retrive from the base storage.
      @return [Array<*>, Object] Properties from base storage.

    @example Get property.
      this.get("sample");

    @example Get mutiple properties.
      this.get(["sample", "pizza"]);

    @example Get all properties.
      this.get();
  ###
  get: (limit, params...) ->
    if not limit?
      limit = for key, item of @data then key
    if typeof limit is "string" or typeof limit is "number" then limit = [limit]
    base = if @data instanceof Array then [] else {}
    for item, i in limit
      data = @["__get#{"#{item}".replace /^[a-z]/, (m) -> m.toUpperCase()}"]? params...
      if not data? then data = @data[item]
      base[item] = data
    if i <= 1 then base = base[item]
    base
    

  ###
    Checks if a property/properties exists from the base storage.
    @param [String, Array<String>] limit Property/properties name to look for in the base storage.
    @param [...] params Parameters to pass into getter method
    @return [Boolean] Returns true or false depending if the property exists in the base storage.

    @overload has(name)
      Get an individual property by a property name.
      @param [String] name The name of the property.
      @return [*] Property from base storage.

    @overload has(limit)
      Get multiple properties from base storage.
      @param [Array<String>] limit Array of property names to retrive from the base storage.
      @return [Array<*>, Object] Properties from base storage.

    @example Get property.
      this.has("sample");

    @example Get mutiple properties.
      this.has(["sample", "pizza"]);
  ###
  has: (limit, params) ->
    if typeof limit is "string" or typeof limit is "number" then limit = [limit]
    for item, i in limit
      data = @["__get#{item.replace /^[a-z]/, (m) -> m.toUpperCase()}"]? params...
      if not data? and not @data[item]? then return false
    true

  ###
    Returns an array of keys where the property matches given value.
    @param [*] value Value to check.
    @return [Array<String>] Returns an array of keys where the property matches given value.
    
    @example find keys of base storage where the value matches.
      this.where(1009); //[3,87]
  ###
  where: (value) ->
    result = []
    data = @data
    for key, prop of data
      if prop is value then result.push key
    return result

  ###
    Reset the Store length to 0 and triggers change event.

    @event changed Triggers a generic event that the Store has been updated.
  ###
  reset: ->
    @length = 0
    @triggerEvent "changed"
    return

  ###
    Import data into the Store.
    @param [Object, Array] data data to import.
    @param [Boolean] silent (optional, default = true) If false events are not triggered upon any changes.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  ###
  import: (data, silent = true) ->
    for key, item of data
      if @data[key]?.import?
        @data[key].import item, silent
      else
        @set key, item, silent
    return

  ###
    Export the Store's data.
    @param [Array<String>] limit (default = all properties) Limit which properties to convert.
    @return [Object] Collection as a JSONString
  ###
  export: (limit) ->
    res = {}
    limit ?= for key, item of @data then key
    for key in limit when (item = @get key)?
      if item.export?
        res[key] = item.export()
      else res[key] = item
    res