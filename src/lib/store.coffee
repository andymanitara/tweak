###
  This is the base Class for dynamic storage based modules. A good way to think of a Store/Model/Collection is to think
  of it as Cache; it can be used to Store data for temporary access. This data can be provided to and from a permanent
  data storage medium. A Store based Class should be used to listen to changes to data and providing actions upon the 
  triggers provided by the event system.

  A Store based class has a getter and setter system. So you can easily apply additional functionality when setting or 
  getting from a Store based class. If there is a method within the Class that uses the naming convention of
  'setter_{name}' or 'getter_{name}' ie 'getter_bike', then this method will be used to get/set the data from the Store
  based Class. This is especially useful when a value of a property is subject to the value of other properties or 
  conditions. The setter and getter naming convention is case sensitive, so if a property is called 'SuperBike' then the 
  getter/setter will be formatted as 'setter_SuperBike'. For more information on how this works please see the methods
  'get' and 'set'. Finally when using the set and get methods, you can pass in as many extra arguments which will be 
  directed to the getter/setter methods.

  Examples are not exact, and will not directly represent valid code; the aim of an example is to be a rough guide. JS
  is chosen as the default language to represent Tweak.js as those using 'compile-to-languages' should have a good
  understanding of JS and be able to translate the examples to a chosen language. Support can be found through the
  community if needed. Please see our Gitter community for more help {http://gitter.im/blake-newman/TweakJS}.
###
class Tweak.Store extends Tweak.Events

  # @property [String] The base object type ie {}, []
  __base: -> {}

  # @property [Integer] Length of the Stores data
  length: 0

  ###
    The constructor initialises its initial data.

    @example Creating a Collection with predefined set of data.
      var collection;
      collection = new tweak.Collection([
        new Model(),
        new Model()
      ]);

    @example Creating a Model with predefined set of data
      var model;
      model = new tweak.Model({
        'demo':true,
        'example':false,
        'position':99
      });
  ###
  constructor: (@_data = @__base()) ->

  ###
    Default initialiser function. By default this is empty, upon initialisation of a component this will be called.
    This acts as your constructor, giving you access to the other modules of the component. Please note you can use a
    constructor method but you will not have access to other modules.
  ###
  init: ->
    
  ###
    Set a single property or multiple properties. Upon setting a property there will be an event triggered; you can use
    this to listen to changes and act upon the changes as required; providing tangle free data binding. 

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
      this.set('sample', 100);

    @example Setting multiple properties.
      this.set({sample:100, second:2});
  
    @example Setting properties silently.
      this.set('sample', 100, true);
      this.set({sample:100, second:2}, true);

    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Store has been updated.
  ###
  set: (data, silent, params...) ->
    if typeof data isnt 'object'
      data = {}[data] = silent
      silent = params.splice 0, 1

    for key, prop of data
      prev = @_data[key]
      if not prev? then @length++
      @_data[key] = @["setter_#{key}"]?(prop, params...) or prop
      if not silent then @triggerEvent "changed:#{key}", prop

    if not silent then @triggerEvent 'changed'
    return

  ###
    Returns whether two objects are the same (similar).
    @param [Object, Array] one Object to compare to Object two.
    @param [Object, Array] two Object to compare to Object one.
    @return [Boolean] Are the two Objects the same/similar?

    @example comparing objects.
      this.same({'sample':true},{'sample':true}); //true
      this.same({'sample':true},{'not':true}); //false
  ###
  same: (one, two) ->
    for key, prop of one when not two[key]? or prop isnt two[key] then return false
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
      this.get('sample');

    @example Get mutiple properties.
      this.get(['sample', 'pizza']);

    @example Get all properties.
      this.get();
  ###
  get: (limit, params...) ->
    if not limit?
      limit = for key, item of @_data then key
    if not limit instanceof Array then limit = [limit]
    base = @__base()
    for item, i in limit
      data = @["getter_#{key}"]? params...
      if not data? then data = @_data[item]
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
      this.has('sample');

    @example Get mutiple properties.
      this.has(['sample', 'pizza']);
  ###
  has: (params) ->
    res =  @get.apply @, params 
    if not res instanceof Array then res = [res]
    for prop in res when not prop? then return false
    true

  ###
    Returns an array of keys where the property matches given value.
    @param [*] value Value to check.
    @return [Array<String>] Returns an array of keys where the property matches given value.
    
    @example find keys of base storage where the value matches.
      this.where(1009); //[3,87]
  ###
  where: (value) -> for key, prop of @_data when prop is value then key

  ###
    Reset the Store length to 0 and triggers change event.

    @event changed Triggers a generic event that the Store has been updated.
  ###
  reset: ->
    @length = 0
    @_data = @__base()
    @triggerEvent 'changed'
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
      if @_data[key]?.import?
        @_data[key].import item, silent
      else
        @set key, item, silent
    return

  ###
    Export the Store's data.
    @param [Array<String>] limit (default = all properties) Limit which properties to convert.
    @return [Object] Collection as a JSONString
  ###
  export: (limit) ->
    res = @__base()
    limit ?= for key, item of @_data then key
    for key in limit when (item = @get key)?
      if item.export?
        res[key] = item.export()
      else res[key] = item
    res