###
  This is the base Class for dynamic storage based modules. A good way to think of a Store/Model/Collection
  is to think it as Cache; it can be used to store data for temporary access. It receives and sends its data
  to a secondary permanent storage solution. The Store class is the base functionality shared between a Model
  and Collection. Classes that inherit store class trigger events when it's storage base is updated, this
  makes it easy to listen to changes and to action as and when required.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples are not exact, and will not
  directly represent valid code; the aim of an example is to show how to roughly use a method.
###
class tweak.Store extends tweak.EventSystem

  # @property [String] The type of storage, i.e. 'collection' or 'model'
  _type: 'BASE'
  # @property [Integer] Length of the stores data
  length: 0
  # @property [Object, Array] Data holder for the store
  data: []
  # @property [Integer] The uid of this object - for unique reference
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
    Set a single or multiple properties or the base storage.

    @overload set(name, data, silent)
      Set an individual property in the store by name
      @param [String] name The name of the property to set
      @param [*] data Data to store in the property being set
      @param [Boolean] silent (optional) (default = false) Silently change the base storage property, by not triggering events upon change

    @overload set(properties, silent)
      Set an multiple properties in the store from an object
      @param [Object] properties Key and property based object
      @param [Boolean] silent (optional) (default = false) Silently change the base storage property, by not triggering events upon change

    @example Setting single property
      this.set("sample", 100);

    @example Setting multiple properties
      this.set({sample:100, second:2});
  
    @example Setting properties silently
      this.set("sample", 100, true);
      this.set({sample:100, second:2}, true);

    @event changed:#{key} Triggers an event and passes in changed property
    @event changed Triggers a generic event that the store has been updated
  ###
  set: (properties, params...) ->
    silent = params[0]
    if typeof properties is 'string'
      prevProps = properties
      properties = {}
      properties[prevProps] = params[0]
      silent = params[1]
    for key, prop of properties
      prev = @data[key]
      if not prev? then @length++
      @data[key] = prop
      
      if not silent then @triggerEvent "changed:#{key}", prop

    if not silent then @triggerEvent "changed"
    return

  ###
    Returns whether two objects are the same (similar)
    @param [Object, Array] one Object to compare
    @param [Object, Array] two Object to compare
    @return [Boolean] Returns whether two object are the same (similar)

    @example comparing objects
      this.same({"sample":true},{"sample":true}); //true
      this.same({"sample":true},{"not":true}); //false
  ###
  same: (one, two) ->
    for key, prop of one
      if not two[key]? or two[key] isnt prop then return false
    true
    
  ###
    Get a property from the base storage
    @param [String] property Property name to look for in the base storage
    @return [*] Returns property value of property in the base storage

    @example Getting property
      this.get("sample");
  ###
  get: (property) -> @data[property]

  ###
    Checks if a property exists from the base storage
    @param [String] property Property name to look for in the base storage
    @return [Boolean] Returns true or false depending if the property exists in the base storage

    @example Checking property exists
      this.has("sample");
  ###
  has: (property) -> @data[property]?

  ###
    Returns an array of property names where the value is equal to the given value
    @param [*] value Value to check
    @return [Array<String>] Returns an array of keys where the value is equal to the given value
    
    @example find keys of base storage where the value matches
      this.where(1009);
  ###
  where: (value) ->
    result = []
    data = @data
    for key, prop of data
      if prop is value then result.push key
    return result

  ###
    Reset the store length to 0 and triggers change event.

    @event changed Triggers a generic event that the store has been updated
  ###
  reset: ->
    @length = 0
    @triggerEvent "changed"
    return