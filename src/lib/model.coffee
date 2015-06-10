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
  
  Examples are not exact, and will not directly represent valid code; the aim of
  an example is to be a rough guide. JS is chosen as the default language to
  represent Tweak.js as those using 'compile-to-languages' should have a good
  understanding of JS and be able to translate the examples to a chosen language.
  Support can be found through the community if needed. Please see our
  Gitter community for more help {http://gitter.im/blake-newman/TweakJS}.
###
class Tweak.Model extends Tweak.Store

  # @property [String] The type of Store, i.e. 'collection' or 'model'.
  _type: 'model'

  ###
    The constructor initialises the controllers unique ID and its initial data.

    @example Creating a Model with predefined set of data
      var model;
      model = new tweak.Model({
        'demo':true,
        'example':false,
        'position':99
      });
  ###
  constructor: (@_data = {}) ->

  ###
    Remove a single property or many properties.
    @param [String, Array<String>] properties Array of property names to remove from a Model, or single String of the name of the property to remove.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event removed:#{key} Triggers an event based on what property has been removed.
    @event changed Triggers a generic event that the Model has been updated.

    @example Removing a single property.
      var model;
      model = new tweak.Model();
      model.remove('demo');

    @example Removing multiple properties.
      var model;
      model = new tweak.Model();
      model.remove(['demo', 'example']);

    @example Removing properties silently.
      var model;
      model = new tweak.Model();
      model.remove(['demo', 'example'], true);
      model.remove('position', true);
  ###
  remove: (properties, silent) ->
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      for key, prop of @_data when key is property
        @length--
        delete @_data[key]
        if not silent then @triggerEvent "removed:#{key}"

    if not silent then @triggerEvent 'changed'
    return

  ###
    Looks through the store for where the data matches.
    @param [*] property The property data to find a match against.
    @return [Array] Returns an array of the positions of the data.
  ###
  pluck: (property) ->
    result = []
    for key, prop of @_data
      if prop is property then result.push key
    result

  ###
    Reset the Model back to defaults.
    @event changed Triggers a generic event that the Model has been updated.
  ###
  reset: ->
    @_data = {}
    super()
    return