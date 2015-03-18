###
  A Collection is used by other modules like the Controller to store, retrieve and
  listen to a set of ordered data. A Collection triggers events when its storage
  base is updated, this makes it easy to listen to changes and to action as and
  when required. The Collection data is not a database, but a JSON representation
  of its data can be exported and imported to and from storage sources. In Tweak.js
  the Model extends the Store module - which is the core functionality shared between
  Model's and Collection's. The main difference between a Model and collection it
  the base of its data type. The Model uses an object as its base data type and a
  collection base type is an Array.

  To further extend a Collection, Tweak.js allows data to be imported and exported.
  When doing this please know that all data stored should be able to be converted
  to a JSON string. A Collection of Models can also be exported and imported to
  and from a database, as it has an inbuilt detection for when a value should be
  created as a Model representation. Keep note that a Collection of Collections is
  not appropriate as this becomes complicated and it can get messy quickly. It
  should be possible to export and import data of that nature, but it’s not
  recommended - always try to keep stored data structured simply.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
###
class tweak.Collection extends tweak.Store
  # @property [String] The type of Store, i.e. 'collection' or 'model'.
  _type: "collection"

  ###
    @private
    Method to trigger a change event for all of the properties in the Collection
  ###
  __fullTrigger = (data, trigger) ->
    for key, item of data then trigger "changed:#{key}", item
    triggerEvent "changed", data

  ###
    The constructor initialises the controllers unique ID and its initial data.

    @example Creating a Collection with predefined set of data.
      var collection;
      collection = new tweak.Collection([
        new Model(),
        new Model()
      ]);
  ###
  constructor: (@data = []) -> @uid = "cl_#{tweak.uids.cl++}"

  ###
    Add a new property to the end of the Collection.
    @param [*] data Data to add to the end of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  ###
  add: (data, silent) ->
    @set @length, data, silent
    return

  ###
    Get an element at specified index.
    @param [Number] index Index of property to return.
    @return [*] Returned data from the specified index.
  ###
  at: (index) -> @data[Number index]

  ###
    Push a new property to the end of the Collection.
    @param [*] data Data to add to the end of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  ###
  push: (data, silent) ->
    @set @length, data, silent
    return

  ###
    Splice method that allows for event triggering on the base object.
    @param [Number] position The position to insert the property at into the Collection.
    @param [Number] remove The amount of properties to remove from the Collection.
    @param [Array<*>] data an array of data to insert into the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.

    @example Removing four properties from the 6th position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.splice(5, 4);

    @example Inserting two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.splice(2, 0, ["100", "200"]);

    @example Silently insert two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.splice(2, 0, ["100", "200"], true);
  ###
  splice: (position, remove, data, silent = false) ->
    @data.splice position, remove, data...
    @length = @data.length
    if not silent then __fullTrigger @data, @triggerEvent
    return

  ###
    Insert values into base data at a given index (Short cut to splice method).
    @param [Number] index The index to insert the property at into the Collection.
    @param [Array<*>] data an array of data to insert into the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.


    @example Inserting two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.insert(2, ["100", "200"]);

    @example Silently insert two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.splice(2, ["100", "200"], true);
  ###
  insert: (index, data, silent) ->
    @splice position, 0, data, silent
    return

  ###
    Adds property to the first index of the Collection.
    @param [Array<*>] data an array of data to insert at the first index of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
    @return [Number] The length of the Collection.
  ###
  unshift: (data, silent) ->
    @splice 0, 0, data, silent
    @length

  ###
    Remove a single property or many properties from the Collection.

    @overload remove(index, silent)
      Remove an individual property from the Collection.
      @param [String] index The index to remove from the Collection.
      @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes to the data.

    @overload remove(data, silent)
      Remove multiple properties from the Collection by an Array of keys (Strings).
      @param [Array] keys An array of keys (indexes) to remove.
      @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes to the data.

    @event removed:#{index} Triggers an event based on what properties have been removed.
    @event changed Triggers a generic event that the Collection has been changed.

    @example Remove a single property.
      var collection;
      collection = new tweak.Collection();
      collection.remove(3);

    @example Remove multiple properties.
      var collection;
      collection = new tweak.Collection();
      collection.remove([1,3]);

    @example Remove properties silently.
      var collection;
      collection = new tweak.Collection();
      collection.remove([4,2], true);
      collection.remove(1, true);
  ###
  remove: (keys, silent) ->
    if not (keys instanceof Array) then keys = [keys]
    for index in keys
      @data.splice index, 1
      if not silent then @triggerEvent "removed:#{index}"
    if not silent then @triggerEvent "changed"
    return

  ###
    Remove an element at a specified index.
    @param [Number] index Index of property to remove.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
    
    @example Remove a property at a given index.
      var collection;
      collection = new tweak.Collection();
      collection.removeAt(1);

    @example Silently remove a property at a given index.
      var collection;
      collection = new tweak.Collection();
      collection.removeAt(3, true);
  ###
  removeAt: (index, silent) ->
    element = @at index
    for key, prop of element
      @remove key, silent
    return

  ###
    Remove a property at the last index of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event removed:#{key} Triggers an event based on what property has been removed.
    @event changed Triggers a generic event that the Collection has been updated.
    @return [*] The property value that was removed.

    @example Remove the last property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.pop();

    @example Silently remove the last property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.pop(true);
  ###
  pop: (silent) ->
    length = @length-1
    result = @data[length]
    @remove length, silent
    result

  ###
    Remove a property at the first index of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event removed:#{key} Triggers an event based on what property has been removed.
    @event changed Triggers a generic event that the Collection has been updated.
    @return [*] The property value that was removed.

    @example Remove the first property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.shift();

    @example Silently remove the first property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.shift(true);
  ###
  shift: (silent) ->
    result = @data[0]
    @remove 0, silent
    result

  ###
    Reduce the collection by removing properties from the first index.
    @param [Number] length The length of the Array to shorten to.

    @example Remove the first five properties from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.reduce(5);

    @example Silently remove the first five property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.reduce(5, true);
  ###
  reduce: (length, silent) ->
    @splice 0, length, silent
    return

  ###
    Reduce the collection by removing properties from the last index.
    @param [Number] length The length of the Array to shorten to.

    @example Remove the first five properties from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.reduce(5);

    @example Silently remove the first five property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.reduce(5, true);
  ###
  reduceRight: (length, silent) ->
    @splice 0, @length-length, silent
    return
  
  ###
    Returns an Array of keys (indexes) where the Collection properties match the specified value.
    @param [*] value The value to find a match against.
    @return [Array] An Array of indexes where the Collection properties match the specified value.

    @example Retrieve the keys (indexes) where the value 'dog' can be found.
      var collection;
      collection = new tweak.Collection();
      collection.indexes('dog');
  ###
  indexes: (value) -> index for index, prop of @data when value is prop

  ###
    Concatenate Arrays to the end of the Collection.
    @param [Array] arrays An Array containing a set of Arrays to concatenate to the end of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes to the data.

    @note As it may be that the Collection is to be updated silently when using this method. The Arrays to concatenate to the end of the Collection has to be wrapped in an Array.
    @example Concatenate a set of Arrays to the end of a collection.
      var collection;
      collection = new tweak.Collection();
      collection.concat([[1,4,6], ["dog", "cat"]);

    @example Silently concatenate a set of Arrays to the end of a collection.
      var collection;
      collection = new tweak.Collection();
      collection.concat([["frog", "toad"]], true);
  ###
  concat: (arrays, silent) ->
    @splice @length-1, 0, [].concat(arrays...), silent
    return


  ###
    Reset the Collection back to defaults
    
    @event changed Triggers a generic event that the store has been updated
  ###
  reset: ->
    @data = []
    super()
    return
  
  ###
    Import and parse a JSONString into the Collection (To one depth only).
    @param [JSONString] data JSONString to parse.
    @param [Object] options Options to parse to method.
    @option options [Array<String>] limit (default = all properties) Limit which properties to convert.
    @option options [Boolean] overwrite (default = true). If true existing properties will be replaced otherwise they are added to the Collection.
    @option options [Boolean] silent (default = false) If true events are not triggered upon any changes.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
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
    return

  ###
    Export the Collection as a JSONString.
    @param [Array<String>] limit (default = all properties) Limit which properties to convert.
    @return [Object] Collection as a JSONString
  ###
  export: (restrict) ->
    res = {}
    for key, item of @data
      res[key] = if item._type
        {type:item._type, data:@parse item.export()}
      else item
    @parse res, limit

  ###
    This method directly accesses the Collection's data's every method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/every
  ###
  every: -> @data.every arguments

  ###
    This method directly accesses the Collection's data's filter method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter
  ###
  filter: -> @data.filter arguments

  ###
    This method directly accesses the Collection's data's forEach method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach
  ###
  forEach: -> @data.forEach arguments

  ###
    This method directly accesses the Collection's data's join method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/join
  ###
  join: -> @data.join arguments

  ###
    This method directly accesses the Collection's data's map method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map
  ###
  map: -> @data.map arguments

  ###
    This method directly accesses the Collection's data's reverse method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reverse

    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  ###
  reverse: (silent) ->
    result = @data.reverse()
    if not silent then __fullTrigger @data, @triggerEvent
    result

  ###
    This method directly accesses the Collection's data's slice method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice
  ###
  slice: -> @data.slice arguments

  ###
    This method directly accesses the Collection's data's some method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/some
  ###
  some: -> @data.some arguments

  ###
    This method directly accesses the Collection's data's sort method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort

    @param [Function] fn (optional) If a comparing function is present then this is passed to sort function.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  ###
  sort: (fn, silent = false) ->
    result = if fn? then @data.sort(fn) else @data.sort()
    __fullTrigger @data, @triggerEvent
    result
