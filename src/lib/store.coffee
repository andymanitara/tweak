###
  This is the base Class for dynamic storage based modules. A good way to think of a Store/Model/Collection is to think
  of it as Cache; it can be used to Store data for temporary access. This data can be provided to and from a permanent
  data storage medium. A Store based Class should be used to listen to changes to data and providing actions upon the 
  triggers provided by the event system.

  A Store based class has a getter and setter system. So you can easily apply additional functionality when setting or 
  getting from a Store based class. 

  When calling the set method of a Store based class, a setter method may be called. If a setter method to the naming
  convention of 'setter_{property name}' is found then the returning value of this setter method will be assigned to
  the property being set. Setter method will have the argument of its corresponding data value that was passed in to the
  set method.

  When calling the get method of a Store based class, a getter method may be called. If a getter method to the naming
  convention of 'getter_{property name}' is found then the returning value of this getter will be returned by the get
  method. A getter method will have the currently stored value as its argument.

  Examples are not exact, and will not directly represent valid code; the aim of an example is to be a rough guide. JS
  is chosen as the default language to represent Tweak.js as those using 'compile-to-languages' should have a good
  understanding of JS and be able to translate the examples to a chosen language. Support can be found through the
  community if needed. Please see our Gitter community for more help {http://gitter.im/blake-newman/TweakJS}.

  @example Creating a setter and getter in Model.
    // This example is very trivial but it illustrates some use of setters and getters
    var QuestionModel, _model, exports;

    module.exports = exports = QuestionModel = (function() {
      function QuestionModel() {}

      Tweak.extends(QuestionModel, Tweak.Model);
      
      // Correct getter will return true or false
      QuestionModel.prototype.getter_correct = function(_prev) {
        _correct = this.get('answer') === this.get('correct_answer');
        // You can use a getter to compare to the previous value
        if (_prev === true && _correct === false) {
          alert('You already got this correct, you should know the answer!'); 
        }
        // You can use the model value as a private property to later use as a comparison
        // In this instance when answer has been answered correct it will be saved to model
        if (_correct === true) {
          // Set correct silently
          this.set('correct', true, true);
        }
        return _correct
      };

      // The answer may only be in the range of 0 - 100
      // This setter will auto validate the answer to within the range, while if its not in range it will trigger an
      // event from the model. For example a notification could be displayed letting the user know his answer was 
      QuestionModel.prototype.setter_answer = function(value) {
        var error;
        error = value > 100 ? 'above' : value < 0 ? 'below' : null;
        if (error) {
          this.trigger('error:range:' + error, value);
        }
        if (error < 0) {
          return 0;
        } else if (value > 100) {
          return 100;
        } else {
          return value;
        }
      };

      return QuestionModel;

    })();

    // Create a new QuestionModel where the answer correct_answer is 10
    _model = new QuestionModel({
      correct_answer: 10
    });
    
    // Listen to answer being set alerting whether the user has got the answer correct
    _model.addEvent('changed:answer', function() {
      return alert('Answer is ' + (this.get('correct') ? 'Correct' : 'Wrong'));
    });
    
    // Listen range error - lets the user knows that his answer was above range
    _model.addEvent('error:range:above', function(value) {
      return alert('Answer (' + value + ') is above max range of 100, answer has been altered to 100');
    });
    
    // Listen range error - lets the user knows that his answer was above range
    _model.addEvent('error:range:below', function(value) {
      return alert('Answer (' + value + ') is below min range of 100, answer has been altered to 0');
    });

    // Alerts 'Answer is Wrong'
    _model.set('answer', 20);

    // Alerts 'Answer (500) is above max range of 100, answer has been altered to 100'
    // Alerts 'Answer is Wrong'
    _model.set('answer', 500);

    // Alerts 'Answer is Correct'
    _model.set('answer', 10);    
    
    // Alerts 'You already got this correct, you should know the answer!'
    // Alerts 'Answer is wrong'
    _model.set('answer', 5);    
    
  
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
    this to listen to changes and act upon the changes as required.     
    @overload set(data, silent)
      Set multiple properties by an object of data.
      @param [Object] data Key and property based object.
      @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes to the data.
      @param [...] params (optional) Extra parameters get passed to setter. Silent argument must be passed when this is.
    
    @overload set(name, data, silent)
      Set an individual property by the name (String) will passing extra parameters to setter
      @param [String] name The name of the property.
      @param [*] data Data to Store in the property.
      @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes to the data.
      @param [...] params (optional) Extra parameters get passed to setter. Silent argument must be passed when this is.
    

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
  set: (data, silent, arg3) ->
    # If there is a third argument then it is assumed that data is a String
    if arg3?
      # Create new Object with property as first argument with 
      data = {}[data] = silent
      silent = arg3

    for key, prop of data
      prev = @_data[key]
      if not prev? then @length++
      fn = @["setter_#{key}"]      
      @_data[key] = if fn? then fn(prop) else prop
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

    @overload get()
      Get all properties from base storage.
      @return [Array<*>, Object] Properties from base storage.

    @overload get(name)
      Get an individual property by a property name.
      @param [String] name The name of the property.
      @return [*] Property from base storage.

    @overload get(limit)
      Get multiple properties from base storage.
      @param [Array<String>] limit Array of property names to retrieve from the base storage.
      @return [Array<*>, Object] Properties from base storage.

    @example Get property.
      this.get('sample');

    @example Get mutiple properties.
      this.get(['sample', 'pizza']);

    @example Get all properties.
      this.get();
  ###
  get: (limit) ->
    if not limit?
      limit = for key, item of @_data then key
    if not limit instanceof Array then limit = [limit]
    base = @__base()
    for item, i in limit
      fn = @["getter_#{key}"]
      _data = @_data[item]
      data = if fn? then fn _data else _data
      base[item] = data
    if i <= 1 then base = base[item]
    base
    

  ###
    Checks if a property/properties exists in the base storage.

    @overload has(name)
      Get an individual property by a property name.
      @param [String] name The name of the property.
      @return [*] Property from base storage.

    @overload has(limit)
      Get multiple properties from base storage.
      @param [Array<String>] limit Array of property names to retrieve from the base storage.
      @return [Array<*>, Object] Properties from base storage.

    @example Get property.
      this.has('sample');

    @example Get mutiple properties.
      this.has(['sample', 'pizza']);
  ###
  has: (limit) ->
    res = @get limit 
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
    Reset the base data and set length to 0 and triggers 'changed' event. 

    @event changed Triggers a generic event that the Store has been updated.
  ###
  reset: ->
    @length = 0
    @_data = @__base()
    @triggerEvent 'changed'
    return

  ###
    Import data into the Store, data can be imported silently. The import method will overwrite properties that already 
    exists; if the existing property has an import method the the data will be passed to this property' method.

    @param [Object, Array] data Data to import.
    @param [Boolean] silent (optional, default = true) If false events are not triggered upon any changes.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Store has been updated.
  ###
  import: (data, silent = true) ->
    for key, item of data
      if @_data[key]?.import?
        @_data[key].import item, silent
      else
        @set key, item, silent
    return

  ###
    Export the Store's data, the data exported can be limited by an array of key names. If the existing property has an 
    export method the the data will be generated by this property' method.

    @param [Array<String>] limit (default = all properties) Limit which properties to convert.
    @return [Object] Store's exported data.
  ###
  export: (limit) ->
    res = @__base()
    limit ?= for key, item of @_data then key
    for key in limit when (item = @get key)?
      if item.export?
        res[key] = item.export()
      else res[key] = item
    res