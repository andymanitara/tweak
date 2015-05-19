;
(function(window){
    
/*
  tweak.js 1.3.0

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
 */

/*
  All of the modules to the source code are separated into the following files
  The order of the merging is determined in the brunch-config.coffee file
 
  tweak.js
    This is the core of the framework - with these modules you can use them in any many of way.
    lib/common.coffee - Common methods used throughout the framework
    lib/class.coffee - Methods to supply JS users the ability to use CoffeScripts OOP methology.
    lib/events.coffee - Event system
    lib/store.coffee - Core/shared code for collections and models
    lib/collection.coffee
    lib/controller.coffee
    lib/model.coffee
    lib/view.coffee
    lib/component.coffee
    lib/components.coffee - collection of components
    lib/router.coffee
    lib/history.coffee
  
  tweak.view.html.js (optional)
    Adds core functionality for rendering templates to views in a web page.
    lib/view_html.coffee
 */

/* Initialise tweak object to the window */
var tweak;

if (typeof exports !== 'undefined') {
  tweak = window.tweak = exports;
} else {
  tweak = window.tweak = {};
}


/*
  A count for the uid's
  Multiple sets of uid codes so its more manageable

  c = component
  cp = components
  v = view
  m = model
  r = router
  cl = collection
  ct = controller
  s = store
 */

tweak.uids = {
  c: 0,
  cp: 0,
  v: 0,
  m: 0,
  r: 0,
  cl: 0,
  ct: 0,
  s: 0
};

    })(window); 

;;
(function(window){
    tweak["__hasProp"] = {}.hasOwnProperty;

tweak.Extends = function(child, parent) {
  var ctor, key;
  ctor = function() {
    this.constructor = child;
  };
  for (key in parent) {
    if (tweak["__hasProp"].call(parent, key)) {
      child[key] = parent[key];
    }
  }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor();
  child.__super__ = parent.prototype;
  return child;
};

tweak.Super = function(context, name) {
  return context.__super__[name].call(this);
};


/*
  TweakJS was initially designed in CoffeeScript for CoffeeScripters. It is much
  easier to use the framework in CoffeeScript; however those using JS the
  following helpers will provide extending features that CoffeeScipt possess.
  These can also be used to reduce the file size of compiled CoffeeScript files.
 */

tweak.Class = (function() {
  function Class() {}


  /*
    To extend an object with JS use tweak.Extends.
    @param [Object] child The child Object to extend.
    @param [Object] parent The parent Object to inheret methods.
    @return [Object] Extended object
   */

  Class.prototype["extends"] = function(child, parent) {};


  /*
    To super a method with JS use this.super from within the class definition.
    To add super to prototype of a custom object not within the TweakJS classes
    in JS; do {class}.prototype.super = tweak.Super
  
    @param [Object] context The context to apply a super call to
    @param [string] name The method name to call super upon.
   */

  Class.prototype["super"] = function(context, name) {};

  return Class;

})();

    })(window); 

;;
(function(window){
    
/*
  This class contains common shared functionality. The aim to reduce repeated code
  and overall file size of the framework.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
 */
tweak.Common = (function() {
  function Common() {}


  /*
    Merge properties from object from one object to another. (First object is the object to take on the properties from the second object).
    @param [Object, Array] one The Object/Array to combine properties into.
    @param [Object, Array] two The Object/Array that shall be combined into the first object.
    @return [Object, Array] Returns the resulting combined object from two Object/Array.
   */

  Common.prototype.combine = function(one, two) {
    var key, prop;
    for (key in two) {
      prop = two[key];
      if (typeof prop === 'object') {
        if (one[key] == null) {
          one[key] = prop instanceof Array ? [] : {};
        }
        one[key] = this.combine(one[key], prop);
      } else {
        one[key] = prop;
      }
    }
    return one;
  };


  /*
    Clone an object to remove reference to original object or simply to copy it.
    @param [Object, Array] ref Reference object to clone.
    @return [Object, Array] Returns the copied object, while removing object references.
   */

  Common.prototype.clone = function(ref) {
    var attr, copy;
    if (null === ref || 'object' !== typeof ref || ref === this) {
      return ref;
    }
    if (ref instanceof Date) {
      copy = new Date();
      copy.setTime(ref.getTime());
      return copy;
    }
    if (ref instanceof Array) {
      copy = [];
    } else if (typeof ref === 'object') {
      copy = {};
    } else {
      throw new Error('Unable to copy object, type not supported.');
    }
    for (attr in ref) {
      if (ref.hasOwnProperty(attr)) {
        copy[attr] = this.clone(ref[attr]);
      }
    }
    return copy;
  };


  /*
    Convert a simple JSON string/object.
    @param [JSONString, JSONObject] data JSONString/JSONObject to convert to vice versa.
    @return [JSONObject, JSONString] Returns JSON data of the opposite data type
   */

  Common.prototype.parse = function(data) {
    return JSON[typeof data === 'string' ? 'parse' : 'data'](data);
  };


  /*
    Try to find a module by name in multiple paths. A final surrogate if available will be returned if no module can be found.
    @param [Array<String>] paths An array of context paths.
    @param [String] module The module path to convert to absolute path; based on the context path.
    @param [Object] surrogate (Optional) A surrogate Object that can be used if there is no module found.
    @return [Object] Returns an Object that has the highest priority.
    @throw When an object cannot be found and no surrogate is provided the following error message will appear -
      "No default module (#{module name}) for component #{component name}".
    @throw When an object is found but there is an error during processing the found object the following message will appear -
      "Module (#{path}) found. Encountered #{e.name}: #{e.message}".
   */

  Common.prototype.findModule = function(contexts, module, surrogate) {
    var context, e, _i, _len;
    for (_i = 0, _len = contexts.length; _i < _len; _i++) {
      context = contexts[_i];
      try {
        return tweak.Common.require(context, module);
      } catch (_error) {
        e = _error;
        if (e.name !== 'Error') {
          e.message = "Module (" + context + "}) found. Encountered " + e.name + ": " + e.message;
          throw e;
        }
      }
    }
    if (surrogate != null) {
      return surrogate;
    }
    throw new Error("No default module (" + module + ") for component " + contexts[0]);
  };


  /*
    Require method to find a module in a given context path and module path.
    The context path and module path are merged together to create an absolute path.
    @param [String] context The context path.
    @param [String] module The module path to convert to absolute path, based on the context path.
    @param [Object] surrogate (Optional) A surrogate Object that can be used if there is no module found.
    @return [Object] Required object or the surrogate if requested.
    @throw Error upon no found module.
   */

  Common.prototype.require = function(context, module, surrogate) {
    var e, path;
    path = tweak.Common.relToAbs(context, module);
    try {
      return require(path);
    } catch (_error) {
      e = _error;
      if (surrogate != null) {
        return surrogate;
      }
      throw e;
    }
  };


  /*
    Split a name out to individual absolute names.
    Names formated like './cd[2-4]' will return an array or something like ['album1/cd2','album1/cd3','album1/cd4'].
    Names formated like './cd[2-4]a ./item[1]/model' will return an array or something
    like ['album1/cd2a','album1/cd3a','album1/cd4a','album1/item0/model','album1/item1/model'].
    @param [String] context The current context's name.
    @param [String, Array<String>] names The string to split into separate component names.
    @return [Array<String>] Array of absolute names.
   */

  Common.prototype.splitMultiName = function(context, names) {
    var item, max, min, prefix, reg, result, suffix, values, _i, _len;
    values = [];
    reg = /^(.*)\[(\d*)(?:[,\-](\d*)){0,1}\](.*)$/;
    if (typeof names === 'string') {
      names = names.split(/\s+/);
    }
    for (_i = 0, _len = names.length; _i < _len; _i++) {
      item = names[_i];
      result = reg.exec(item);
      if (result != null) {
        prefix = result[1];
        min = result[2] || 0;
        max = result[3] || min;
        suffix = result[4];
        while (min <= max) {
          values.push(this.relToAbs(context, "" + prefix + (min++) + suffix));
        }
      } else {
        values.push(this.relToAbs(context, item));
      }
    }
    return values;
  };


  /*
    Convert relative path to an absolute path; relative path defined by ./ or .\
    It will also reduce the prefix path by one level per ../ in the path.
    @param [String] context The context path.
    @param [String] name The path to convert to absolute path, based on the context path.
    @return [String] Absolute path.
   */

  Common.prototype.relToAbs = function(context, name) {
    var amount;
    amount = name.split(/\.{2,}[\/\\]*/).length - 1 || 0;
    context = context.replace(new RegExp("([\\/\\\\]*[^\\/\\\\]+){" + amount + "}[\\/\\\\]?$"), '');
    return name.replace(/^(\.+[\/\\]*)+/, "" + context + "/");
  };


  /*
    Apply event listener to a DOMElement, with cross/old browser support.
    @param [DOMElement] element A DOMElement.
    @param [String] type The type of event.
    @param [Function] callback The method to add to the events callbacks.
    @param [Boolean] capture (Default = false) After initiating capture, all events of
      the specified type will be dispatched to the registered listener before being
      dispatched to any EventTarget beneath it in the DOM tree. Events which are bubbling
      upward through the tree will not trigger a listener designated to use capture. If
      a listener was registered twice, one with capture and one without, each must be
      removed separately. Removal of a capturing listener does not affect a non-capturing
      version of the same listener, and vice versa.
   */

  Common.prototype.on = function(element, type, callback, capture) {
    var event, fn, key, res, _base, _ref;
    if (capture == null) {
      capture = false;
    }
    if (element.__events == null) {
      element.__events = {};
    }
    _ref = (_base = element.__events)[type] != null ? _base[type] : _base[type] = [];
    for (key in _ref) {
      event = _ref[key];
      if (!(((callback == null) || event.callback === callback) && event.capture === capture)) {
        continue;
      }
      element.__events[type][key].enabled = true;
      res = true;
    }
    if (res) {
      return;
    }
    element.__events[type].push({
      element: element,
      type: type,
      callback: callback,
      capture: capture,
      enabled: true
    });
    fn = function(e) {
      var _i, _len, _ref1, _results;
      _ref1 = element.__events[type];
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        event = _ref1[_i];
        if (event.enabled) {
          _results.push(event.callback(e, event.element));
        }
      }
      return _results;
    };
    if (window.addEventListener) {
      element.addEventListener(type, fn, capture);
    } else if (window.attachEvent) {
      element.attachEvent("on" + type, fn);
    } else {
      element["on" + type] = fn;
    }
  };


  /*
    Remove event listener to a DOMElement, with cross/old browser support.
    @param [DOMElement] element A DOMElement.
    @param [String] type The type of event.
    @param [Function] callback The method to remove from the events callbacks.
    @param [Boolean] capture (Default = false) Specifies whether the EventListener being
      removed was registered as a capturing listener or not. If a listener was registered
      twice, one with capture and one without, each must be removed separately. Removal of
      a capturing listener does not affect a non-capturing version of the same listener,
      and vice versa.
   */

  Common.prototype.off = function(element, type, callback, capture) {
    var event, key, _base, _ref;
    if (capture == null) {
      capture = false;
    }
    if (element.__events == null) {
      element.__events = {};
    }
    _ref = (_base = element.__events)[type] != null ? _base[type] : _base[type] = [];
    for (key in _ref) {
      event = _ref[key];
      if (((callback == null) || event.callback === callback) && event.capture === capture) {
        element.__events[type][key].enabled = false;
      }
    }
  };


  /*
    Trigger event listener on a DOMElement, with cross/old browser support.
    @param [DOMElement] element A DOMElement to trigger event on.
    @param [Event, String] event Event to trigger or string if to create new event.
   */

  Common.prototype.trigger = function(element, event) {
    var doc;
    doc = window.document;
    if (doc.createEvent) {
      if (typeof event === 'string') {
        event = new Event(event);
      }
      event.root = element;
      element.dispatchEvent(event);
    } else {
      if (typeof event === 'string') {
        event = doc.createEventObject();
      }
      event.root = element;
      element.fireEvent("on" + event, event);
    }
  };

  return Common;

})();

tweak.Common = new tweak.Common();

    })(window); 

;;
(function(window){
    
/*
  Tweak.js has an event system class, this provides functionality to extending
  classes to communicate simply and effectively while maintaining an organised
  structure to your code and applications. Each object can extend the
  tweak.EventSystem class to provide event functionality to classes. Majority of
  Tweak.js modules/classes already extend the EventSystem class, however when
  creating custom objects/classes you can extend the class using the tweak.Extends
  method, please see the Class class in the documentation.
    
  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
 */
var __slice = [].slice;

tweak.Events = (function() {
  function Events() {}


  /*
    Iterate through events to find matching named events. Can be used to add a new event through the optional Boolean build argument
  
    @overload findEvent(names, build)
      Find events with a space separated string.
      @param [String] names The event name(s); split on a space.
      @param [Boolean] build (Default = false) Whether or not to add an event object when none can be found.
      @return [Array<Event>] All event objects that are found/created then it is returned in an Array.
  
    @overload findEvent(names, build)
      Find events with an array of names (strings).
      @param [Array<String>] names An array of names (strings).
      @param [Boolean] build (Default = false) Whether or not to add an event object when none can be found.
      @return [Array<Event>] All event objects that are found/created then it is returned in an Array.
  
    @example Delimited string
      // This will find all events in the given space delimited string.
      var model;
      model = new Model();
      model.findEvent('sample:event another:event');
  
    @example Delimited string with build
      // This will find all events in the given space delimited string.
      // If event cannot be found then it will be created.
      var model;
      model = new Model();
      model.findEvent('sample:event another:event', true);
  
    @example Array of names (strings)
      // This will find all events from the names in the given array.
      var model;
      model = new Model();
      model.findEvent(['sample:event', 'another:event']);
  
    @example Array of names (strings) with build
      // This will find all events from the names in the given array.
      // If event cannot be found then it will be created.
      var model;
      model = new Model();
      model.findEvent(['sample:event', 'another:event'], true);
   */

  Events.prototype.findEvent = function(names, build) {
    var event, events, item, _i, _len, _results;
    if (build == null) {
      build = false;
    }
    if (typeof names === 'string') {
      names = names.split(/\s+/);
    }
    events = this.__events = this.__events || {};
    _results = [];
    for (_i = 0, _len = names.length; _i < _len; _i++) {
      item = names[_i];
      if (!(event = events[item])) {
        if (build) {
          event = this.__events[item] = {
            name: item,
            __callbacks: []
          };
        } else {
          continue;
        }
      }
      _results.push(event);
    }
    return _results;
  };


  /*
    Bind a callback to the event system. The callback is invoked when an
    event is triggered. Events are added to an object based on their name.
  
    Name spacing is useful to separate events into their relevant types.
    It is typical to use colons for name spacing. However you can use any other
    name spacing characters such as / \ - _ or .
    
    @overload addEvent(names, callback, context, max)
      Bind a callback to event(s) with context and/or total calls
      @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @param [Function] callback The event callback function.
      @param [Object] context (optional, default = this) The contextual object of which the event to be bound to.
      @param [Number] max (optional, default = null). The maximum calls on the event listener. After the total calls the events callback will not invoke.
  
    @overload addEvent(names, callback, max, context)
      Bind a callback to event(s) with total calls and/or context
      @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @param [Function] callback The event callback function.
      @param [Number] max The maximum calls on the event listener. After the total calls the events callback will not invoke.
      @param [Object] context (optional, default = this) The contextual object of which the event to be bound to.
  
    @example Bind a callback to event(s)
      var model;
      model = new Model();
      model.addEvent('sample:event', function(){
        alert('Sample event triggered.')
      });
    
    @example Bind a callback to event(s) with total calls
      var model;
      model = new Model();
      model.addEvent('sample:event', function(){
        alert('Sample event triggered.')
      }, 4);
  
    @example Bind a callback to event(s) with a separate context without total calls
      var model;
      model = new Model();
      model.addEvent('sample:event', function(){
        alert('Sample event triggered.')
      }, this);
  
    @example Bind a callback to event(s) with a separate context with maximum calls
      var model;
      model = new Model();
      model.addEvent('sample:event', function(){
        alert('Sample event triggered.')
      }, this, 3);
   */

  Events.prototype.addEvent = function(names, callback, context, max) {
    var event, ignore, item, _i, _j, _len, _len1, _ref, _ref1;
    if (context == null) {
      context = this;
    }
    if (typeof context === 'number' || context === null) {
      max = context;
      context = max || this;
    }
    _ref = this.findEvent(names, true);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      event = _ref[_i];
      ignore = false;
      _ref1 = event.__callbacks;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        item = _ref1[_j];
        if (item.callback === callback && context === item.ctx) {
          item.max = max;
          item.calls = 0;
          item.listen = ignore = true;
        }
      }
      if (!ignore) {
        event.__callbacks.push({
          ctx: context,
          callback: callback,
          max: max,
          calls: 0,
          listen: true
        });
      }
    }
  };


  /*
    Remove a previously bound callback function. Removing events can be limited to context and its callback.
    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Function] callback (optional) The callback function of the event. If no specific callback is given then all the events under event name are removed.
    @param [Object] context (default = this) The contextual object of which the event is bound to. If this matches then it will be removed, however if set to null then all events no matter of context will be removed.
  
    @example Unbind a callback from event(s)
      var model;
      model = new Model();
      model.removeEvent('sample:event another:event', @callback);
  
    @example Unbind all callbacks from event(s)
      var model;
      model = new Model();
      model.removeEvent('sample:event another:event');
   */

  Events.prototype.removeEvent = function(names, callback, context) {
    var event, item, key, _i, _len, _ref, _ref1;
    if (context == null) {
      context = this;
    }
    _ref = this.findEvent(names);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      event = _ref[_i];
      _ref1 = event.__callbacks;
      for (key in _ref1) {
        item = _ref1[key];
        if (((callback == null) || callback === item.callback) && ((context == null) || context === item.ctx)) {
          event.__callbacks.splice(key, 1);
        }
      }
      if (event.__callbacks.length === 0) {
        delete this.__events[event.name];
      }
    }
  };


  /*
    Trigger events by name.
    @overload triggerEvent(names, params)
      Trigger events by name only.
      @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @param [...] params Parameters to pass into the callback function.
  
    @overload triggerEvent(options, params)
      Trigger events by name and context.
      @param [Object] options Options and limiters to check against callbacks.
      @param [...] params Parameters to pass into the callback function.
      @option options [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @option options [Context] context (Default = null) The context of the callback to check against a callback.
  
    @example Triggering event(s)
      var model;
      model = new Model();
      model.triggerEvent('sample:event, another:event');
  
    @example Triggering event(s) with parameters
      var model;
      model = new Model();
      model.triggerEvent('sample:event another:event', 'whats my name', 'its...');
  
    @example Triggering event(s) but only with matching context
      var model;
      model = new Model();
      model.triggerEvent({context:@, name:'sample:event another:event'});
   */

  Events.prototype.triggerEvent = function() {
    var context, event, item, names, params, _i, _j, _len, _len1, _ref, _ref1;
    names = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (typeof names === 'object' && !names instanceof Array) {
      names = names.names || [];
      context = names.context || null;
    }
    _ref = this.findEvent(names);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      event = _ref[_i];
      _ref1 = event.__callbacks;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        item = _ref1[_j];
        if (item.listen && ((context == null) || context === item.ctx)) {
          if ((item.max != null) && ++item.calls >= item.max) {
            item.listen = false;
          }
          setTimeout((function() {
            this.callback.apply(this.ctx, params);
          }).bind(item), 0);
        }
      }
    }
  };


  /*
    Set events listening state, maximum calls, and total calls limited by name and options (callback, context).
    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Object] options Optional limiters and update values.
    @option options [Object] context The contextual object to limit updating events to.
    @option options [Function] callback Callback function to limit updating events to.
    @option options [Number] max Set a new maximum calls to an event.
    @option options [Number] calls Set the amount of calls that has been triggered on this event.
    @option options [Boolean] reset (Default = false) If true then calls on an event get set back to 0.
    @option options [Boolean] listen Whether to enable or disable listening to event.
  
    @example Updating event(s) to not listen
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {listen:false});
  
    @example Updating event(s) to not listen, however limited by optional context and/or callback
      // Limit events that match to a context and callback.
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {context:@, callback:@callback, listen:false});
  
      // Limit events that match to a callback.
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {callback:@anotherCallback, listen:false});
  
      // Limit events that match to a context.
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {context:@, listen:false});
  
    @example Updating event(s) maximum calls and reset its current calls
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {reset:true, max:100});
  
    @example Updating event(s) total calls
      var model;
      model = new Model();
      model.updateEvent('sample:event, another:event', {calls:29});
   */

  Events.prototype.updateEvent = function(names, options) {
    var callback, calls, ctx, event, item, listen, max, reset, _i, _j, _len, _len1, _ref, _ref1;
    if (options == null) {
      options = {};
    }
    ctx = options.context;
    max = options.max;
    reset = options.reset;
    calls = reset ? 0 : options.calls || 0;
    listen = options.listen;
    callback = options.callback;
    _ref = this.findEvent(names);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      event = _ref[_i];
      _ref1 = event.__callbacks;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        item = _ref1[_j];
        if (((ctx == null) || ctx !== item.ctx) && ((callback == null) || callback !== item.callback)) {
          if (max != null) {
            item.max = max;
          }
          if (calls != null) {
            item.calls = calls;
          }
          if (listen != null) {
            item.listen = listen;
          }
        }
      }
    }
  };


  /*
    Resets the events on this object to empty.
   */

  Events.prototype.resetEvents = function() {
    return this.__events = {};
  };

  return Events;

})();

    })(window); 

;;
(function(window){
    
/*
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
 */
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

tweak.Store = (function(_super) {
  __extends(Store, _super);

  Store.prototype._type = 'BASE';

  Store.prototype.length = 0;

  Store.prototype.data = [];

  Store.prototype.uid = 0;

  Store.prototype.parse = tweak.Common.parse;

  Store.prototype["super"] = tweak["super"];


  /*
    The constructor initialises the controllers unique ID.
   */

  function Store() {
    this.uid = "s_" + (tweak.uids.s++);
  }


  /*
    Default initialiser function
   */

  Store.prototype.init = function() {};


  /*
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
      this.set('sample', 100);
  
    @example Setting multiple properties.
      this.set({sample:100, second:2});
  
    @example Setting properties silently.
      this.set('sample', 100, true);
      this.set({sample:100, second:2}, true);
  
    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Store has been updated.
   */

  Store.prototype.set = function() {
    var data, key, obj, params, prev, prevProps, prop, silent, type, _name;
    data = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    silent = params[0];
    type = typeof data;
    if (type === 'string' || type === 'number') {
      prevProps = data;
      data = {};
      data[prevProps] = params[0];
      silent = params[1];
    }
    obj = {};
    for (key in data) {
      prop = data[key];
      prev = this.data[key];
      if (prev == null) {
        this.length++;
      }
      this.data[key] = (typeof this[_name = "__set" + (key.replace(/^[a-z]/, function(m) {
        return m.toUpperCase();
      }))] === "function" ? this[_name](prop) : void 0) || prop;
      if (!silent) {
        this.triggerEvent("changed:" + key, prop);
      }
    }
    if (!silent) {
      this.triggerEvent('changed');
    }
  };


  /*
    Returns whether two objects are the same (similar).
    @param [Object, Array] one Object to compare to Object two.
    @param [Object, Array] two Object to compare to Object one.
    @return [Boolean] Are the two Objects the same/similar?
  
    @example comparing objects.
      this.same({'sample':true},{'sample':true}); //true
      this.same({'sample':true},{'not':true}); //false
   */

  Store.prototype.same = function(one, two) {
    var key, prop;
    for (key in one) {
      prop = one[key];
      if ((two[key] == null) || two[key] !== prop) {
        return false;
      }
    }
    return true;
  };


  /*
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
   */

  Store.prototype.get = function() {
    var base, data, i, item, key, limit, params, _i, _len, _name;
    limit = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (limit == null) {
      limit = (function() {
        var _ref, _results;
        _ref = this.data;
        _results = [];
        for (key in _ref) {
          item = _ref[key];
          _results.push(key);
        }
        return _results;
      }).call(this);
    }
    if (typeof limit === 'string' || typeof limit === 'number') {
      limit = [limit];
    }
    base = this.data instanceof Array ? [] : {};
    for (i = _i = 0, _len = limit.length; _i < _len; i = ++_i) {
      item = limit[i];
      data = typeof this[_name = "__get" + (("" + item).replace(/^[a-z]/, function(m) {
        return m.toUpperCase();
      }))] === "function" ? this[_name].apply(this, params) : void 0;
      if (data == null) {
        data = this.data[item];
      }
      base[item] = data;
    }
    if (i <= 1) {
      base = base[item];
    }
    return base;
  };


  /*
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
   */

  Store.prototype.has = function(limit, params) {
    var data, i, item, _i, _len, _name;
    if (typeof limit === 'string' || typeof limit === 'number') {
      limit = [limit];
    }
    for (i = _i = 0, _len = limit.length; _i < _len; i = ++_i) {
      item = limit[i];
      data = typeof this[_name = "__get" + (item.replace(/^[a-z]/, function(m) {
        return m.toUpperCase();
      }))] === "function" ? this[_name].apply(this, params) : void 0;
      if ((data == null) && (this.data[item] == null)) {
        return false;
      }
    }
    return true;
  };


  /*
    Returns an array of keys where the property matches given value.
    @param [*] value Value to check.
    @return [Array<String>] Returns an array of keys where the property matches given value.
    
    @example find keys of base storage where the value matches.
      this.where(1009); //[3,87]
   */

  Store.prototype.where = function(value) {
    var data, key, prop, result;
    result = [];
    data = this.data;
    for (key in data) {
      prop = data[key];
      if (prop === value) {
        result.push(key);
      }
    }
    return result;
  };


  /*
    Reset the Store length to 0 and triggers change event.
  
    @event changed Triggers a generic event that the Store has been updated.
   */

  Store.prototype.reset = function() {
    this.length = 0;
    this.triggerEvent('changed');
  };


  /*
    Import data into the Store.
    @param [Object, Array] data data to import.
    @param [Boolean] silent (optional, default = true) If false events are not triggered upon any changes.
  
    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
   */

  Store.prototype["import"] = function(data, silent) {
    var item, key, _ref;
    if (silent == null) {
      silent = true;
    }
    for (key in data) {
      item = data[key];
      if (((_ref = this.data[key]) != null ? _ref["import"] : void 0) != null) {
        this.data[key]["import"](item, silent);
      } else {
        this.set(key, item, silent);
      }
    }
  };


  /*
    Export the Store's data.
    @param [Array<String>] limit (default = all properties) Limit which properties to convert.
    @return [Object] Collection as a JSONString
   */

  Store.prototype["export"] = function(limit) {
    var item, key, res, _i, _len;
    res = {};
    if (limit == null) {
      limit = (function() {
        var _ref, _results;
        _ref = this.data;
        _results = [];
        for (key in _ref) {
          item = _ref[key];
          _results.push(key);
        }
        return _results;
      }).call(this);
    }
    for (_i = 0, _len = limit.length; _i < _len; _i++) {
      key = limit[_i];
      if ((item = this.get(key)) != null) {
        if (item["export"] != null) {
          res[key] = item["export"]();
        } else {
          res[key] = item;
        }
      }
    }
    return res;
  };

  return Store;

})(tweak.Events);

    })(window); 

;;
(function(window){
    
/*
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
 */
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

tweak.Model = (function(_super) {
  __extends(Model, _super);

  Model.prototype.data = {};

  Model.prototype._type = 'model';


  /*
    The constructor initialises the controllers unique ID and its initial data.
  
    @example Creating a Model with predefined set of data
      var model;
      model = new tweak.Model({
        'demo':true,
        'example':false,
        'position':99
      });
   */

  function Model(data) {
    this.data = data != null ? data : {};
    this.uid = "m_" + (tweak.uids.m++);
  }


  /*
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
   */

  Model.prototype.remove = function(properties, silent) {
    var key, prop, property, _i, _len, _ref;
    if (typeof properties === 'string') {
      properties = [properties];
    }
    for (_i = 0, _len = properties.length; _i < _len; _i++) {
      property = properties[_i];
      _ref = this.data;
      for (key in _ref) {
        prop = _ref[key];
        if (!(key === property)) {
          continue;
        }
        this.length--;
        delete this.data[key];
        if (!silent) {
          this.triggerEvent("removed:" + key);
        }
      }
    }
    if (!silent) {
      this.triggerEvent('changed');
    }
  };


  /*
    Looks through the store for where the data matches.
    @param [*] property The property data to find a match against.
    @return [Array] Returns an array of the positions of the data.
   */

  Model.prototype.pluck = function(property) {
    var key, prop, result, _ref;
    result = [];
    _ref = this.data;
    for (key in _ref) {
      prop = _ref[key];
      if (prop === property) {
        result.push(key);
      }
    }
    return result;
  };


  /*
    Reset the Model back to defaults.
    @event changed Triggers a generic event that the Model has been updated.
   */

  Model.prototype.reset = function() {
    this.data = {};
    Model.__super__.reset.call(this);
  };

  return Model;

})(tweak.Store);

    })(window); 

;;
(function(window){
    
/*
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
 */
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

tweak.Collection = (function(_super) {
  var __fullTrigger;

  __extends(Collection, _super);

  Collection.prototype._type = 'collection';


  /*
    @private
    Method to trigger a change event for all of the properties in the Collection
   */

  __fullTrigger = function(data, trigger) {
    var item, key;
    for (key in data) {
      item = data[key];
      trigger("changed:" + key, item);
    }
    return triggerEvent('changed', data);
  };


  /*
    The constructor initialises the controllers unique ID and its initial data.
  
    @example Creating a Collection with predefined set of data.
      var collection;
      collection = new tweak.Collection([
        new Model(),
        new Model()
      ]);
   */

  function Collection(data) {
    this.data = data != null ? data : [];
    this.uid = "cl_" + (tweak.uids.cl++);
  }


  /*
    Add a new property to the end of the Collection.
    @param [*] data Data to add to the end of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
  
    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
   */

  Collection.prototype.add = function(data, silent) {
    this.set(this.length, data, silent);
  };


  /*
    Get an element at specified index.
    @param [Number] index Index of property to return.
    @return [*] Returned data from the specified index.
   */

  Collection.prototype.at = function(index) {
    return this.get(index);
  };


  /*
    Push a new property to the end of the Collection.
    @param [*] data Data to add to the end of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
  
    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
   */

  Collection.prototype.push = function(data, silent) {
    this.set(this.length, data, silent);
  };


  /*
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
      collection.splice(2, 0, ['100', '200']);
  
    @example Silently insert two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.splice(2, 0, ['100', '200'], true);
   */

  Collection.prototype.splice = function(position, remove, data, silent) {
    var _ref;
    if (silent == null) {
      silent = false;
    }
    (_ref = this.data).splice.apply(_ref, [position, remove].concat(__slice.call(data)));
    this.length = this.data.length;
    if (!silent) {
      __fullTrigger(this.data, this.triggerEvent);
    }
  };


  /*
    Insert values into base data at a given index (Short cut to splice method).
    @param [Number] index The index to insert the property at into the Collection.
    @param [Array<*>] data an array of data to insert into the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
  
    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  
  
    @example Inserting two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.insert(2, ['100', '200']);
  
    @example Silently insert two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.splice(2, ['100', '200'], true);
   */

  Collection.prototype.insert = function(index, data, silent) {
    this.splice(position, 0, data, silent);
  };


  /*
    Adds property to the first index of the Collection.
    @param [Array<*>] data an array of data to insert at the first index of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
  
    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
    @return [Number] The length of the Collection.
   */

  Collection.prototype.unshift = function(data, silent) {
    this.splice(0, 0, data, silent);
    return this.length;
  };


  /*
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
   */

  Collection.prototype.remove = function(keys, silent) {
    var index, _i, _len;
    if (!(keys instanceof Array)) {
      keys = [keys];
    }
    for (_i = 0, _len = keys.length; _i < _len; _i++) {
      index = keys[_i];
      this.data.splice(index, 1);
      if (!silent) {
        this.triggerEvent("removed:" + index);
      }
    }
    if (!silent) {
      this.triggerEvent('changed');
    }
  };


  /*
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
   */

  Collection.prototype.removeAt = function(index, silent) {
    var element, key, prop;
    element = this.at(index);
    for (key in element) {
      prop = element[key];
      this.remove(key, silent);
    }
  };


  /*
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
   */

  Collection.prototype.pop = function(silent) {
    var length, result;
    length = this.length - 1;
    result = this.data[length];
    this.remove(length, silent);
    return result;
  };


  /*
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
   */

  Collection.prototype.shift = function(silent) {
    var result;
    result = this.data[0];
    this.remove(0, silent);
    return result;
  };


  /*
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
   */

  Collection.prototype.reduce = function(length, silent) {
    this.splice(0, length, silent);
  };


  /*
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
   */

  Collection.prototype.reduceRight = function(length, silent) {
    this.splice(0, this.length - length, silent);
  };


  /*
    Returns an Array of keys (indexes) where the Collection properties match the specified value.
    @param [*] value The value to find a match against.
    @return [Array] An Array of indexes where the Collection properties match the specified value.
  
    @example Retrieve the keys (indexes) where the value 'dog' can be found.
      var collection;
      collection = new tweak.Collection();
      collection.indexes('dog');
   */

  Collection.prototype.indexes = function(value) {
    var index, prop, _ref, _results;
    _ref = this.data;
    _results = [];
    for (index in _ref) {
      prop = _ref[index];
      if (value === prop) {
        _results.push(index);
      }
    }
    return _results;
  };


  /*
    Concatenate Arrays to the end of the Collection.
    @param [Array] arrays An Array containing a set of Arrays to concatenate to the end of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes to the data.
  
    @note As it may be that the Collection is to be updated silently when using this method. The Arrays to concatenate to the end of the Collection has to be wrapped in an Array.
    @example Concatenate a set of Arrays to the end of a collection.
      var collection;
      collection = new tweak.Collection();
      collection.concat([[1,4,6], ['dog', 'cat']);
  
    @example Silently concatenate a set of Arrays to the end of a collection.
      var collection;
      collection = new tweak.Collection();
      collection.concat([['frog', 'toad']], true);
   */

  Collection.prototype.concat = function(arrays, silent) {
    var _ref;
    this.splice(this.length - 1, 0, (_ref = []).concat.apply(_ref, arrays), silent);
  };


  /*
    Reset the Collection back to defaults
    
    @event changed Triggers a generic event that the store has been updated
   */

  Collection.prototype.reset = function() {
    this.data = [];
    Collection.__super__.reset.call(this);
  };


  /*
    This method directly accesses the Collection's data's every method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/every
   */

  Collection.prototype.every = function() {
    return this.data.every(arguments);
  };


  /*
    This method directly accesses the Collection's data's filter method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter
   */

  Collection.prototype.filter = function() {
    return this.data.filter(arguments);
  };


  /*
    This method directly accesses the Collection's data's forEach method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach
   */

  Collection.prototype.forEach = function() {
    return this.data.forEach(arguments);
  };


  /*
    This method directly accesses the Collection's data's join method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/join
   */

  Collection.prototype.join = function() {
    return this.data.join(arguments);
  };


  /*
    This method directly accesses the Collection's data's map method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map
   */

  Collection.prototype.map = function() {
    return this.data.map(arguments);
  };


  /*
    This method directly accesses the Collection's data's reverse method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reverse
  
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
  
    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
   */

  Collection.prototype.reverse = function(silent) {
    var result;
    result = this.data.reverse();
    if (!silent) {
      __fullTrigger(this.data, this.triggerEvent);
    }
    return result;
  };


  /*
    This method directly accesses the Collection's data's slice method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice
   */

  Collection.prototype.slice = function() {
    return this.data.slice(arguments);
  };


  /*
    This method directly accesses the Collection's data's some method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/some
   */

  Collection.prototype.some = function() {
    return this.data.some(arguments);
  };


  /*
    This method directly accesses the Collection's data's sort method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort
  
    @param [Function] fn (optional) If a comparing function is present then this is passed to sort function.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
  
    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
   */

  Collection.prototype.sort = function(fn, silent) {
    var result;
    if (silent == null) {
      silent = false;
    }
    result = fn != null ? this.data.sort(fn) : this.data.sort();
    __fullTrigger(this.data, this.triggerEvent);
    return result;
  };

  return Collection;

})(tweak.Store);

    })(window); 

;;
(function(window){
    
/*
  A Controller defines the business logic between other modules. It can be used to
  control data flow, logic and more. It should process the data from the Model,
  interactions and responses from the View, and control the logic between other
  modules.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
 */
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

tweak.Controller = (function(_super) {
  __extends(Controller, _super);

  Controller.prototype.uid = 0;

  Controller.prototype["super"] = tweak["super"];


  /*
    The constructor initialises the Controllers unique ID.
   */

  function Controller() {
    this.uid = "ct_" + (tweak.uids.ct++);
  }


  /*
    By default, this does nothing during initialization unless it is overridden.
   */

  Controller.prototype.init = function() {};

  return Controller;

})(tweak.Events);

    })(window); 

;;
(function(window){
    
/*
  The core View.
  
  A View is a module used as a presentation layer. Which is used to render,
  manipulate and listen to an interface. The Model, View and Controller separates
  logic of the Views interaction to that of data and functionality. This helps to
  keep code organized and tangle free - the View should primarily be used to render,
  manipulate and listen to the presentation layer. A View consists of a template to
  which data is bound to and rendered/re-rendered.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
 */
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

tweak.View = (function(_super) {
  __extends(View, _super);

  View.prototype.uid = 0;

  View.prototype["super"] = tweak["super"];


  /*
    The constructor initialises the controllers unique ID and its root context and sets the Views configuration.
   */

  function View(config) {
    this.config = config != null ? config : {};
    this.uid = "v_" + (tweak.uids.v++);
  }


  /*
    Default initialiser function - called when the View has rendered.
   */

  View.prototype.init = function() {};


  /*
    Renders the View.
    @event rendered View has been rendered.
   */

  View.prototype.render = function(silent) {
    if (!silent) {
      this.triggerEvent('rendered');
    }
  };


  /*
    Re-renders the View.
    @event rendered View has been rendered.
    @event rerendered View has been re-rendered.
   */

  View.prototype.rerender = function(silent) {
    this.clear();
    this.render(silent);
    if (!silent) {
      this.addEvent('rendered', function() {
        return this.triggerEvent('rerendered');
      }, this, 1);
    }
  };


  /*
    Checks to see if the item is rendered; this is determined if the node has a parentNode.
    @return [Boolean] Returns whether the View has been rendered.
   */

  View.prototype.isRendered = function() {
    return true;
  };


  /*
    Clears the View
   */

  View.prototype.clear = function() {};

  return View;

})(tweak.Events);

    })(window); 

;;
(function(window){
    
/*
  Simple cross browser history API. Upon changes to the history a change event is
  called. The ability to hook event listeners to the tweak.History API allows
  routes to be added accordingly, and for multiple Routers to be declared for
  better code structure.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
 */
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

tweak.History = (function(_super) {
  __extends(History, _super);

  History.prototype.usePush = true;

  History.prototype.useHash = false;

  History.prototype.started = false;

  History.prototype.root = '/';

  History.prototype.iframe = null;

  History.prototype.url = null;

  History.prototype.__interval = null;

  History.prototype.intervalRate = 50;


  /*
    Checks that the window and history is available.
    This addr support for the history to work outside of browsers
    if the window, history and location are set manually.
   */

  function History() {
    this.__checkChanged = __bind(this.__checkChanged, this);
    if (typeof window !== 'undefined') {
      this.location = (this.window = window).location;
      this.history = window.history;
    }
  }


  /*
    Start listening to the URL changes to push back the history API if available.
    
    @param [Object] options An optional object to pass in optional arguments
    @option options [Boolean] pushState (default = true) Specify whether to use pushState if false then hashState will be used.
    @option options [Boolean] hashState (default = false) Specify whether to use hashState if true then pushState will be set to false.
    @option options [Boolean] forceRefresh (default = false) When set to true then pushState and hashState will not be used.
    @option options [Number] interval (default = null) When set to a number this is what the refresh rate will be when an interval has to be used to check changes to the URL.
    @option options [Boolean] silent (default = false) If set to true then an initial change event trigger will not be called.
    
    @event changed When the URL is updated a change event is fired from tweak.History.
  
    @example Starting the history with auto configuration.
      tweak.History.start();
  
    @example Starting the history with forced HashState.
      tweak.History.start({
        hashState:true
      });
  
    @example Starting the history with forced PushState.
      tweak.History.start({
        pushState:true
      });
  
    @example Starting the history with forced refresh or page.
      tweak.History.start({
        forceRefresh:true
      });
  
    @example Starting the history with an interval rate for the polling speed for older browsers.
      tweak.History.start({
        hashState:true,
        interval: 100
      });
  
    @example Starting the history silently.
      tweak.History.start({
        hashState:true,
        silent: true
      });
   */

  History.prototype.start = function(options) {
    var atRoot, body, frame, location, root, url, useHash, usePush, _ref;
    if (options == null) {
      options = {};
    }
    if (this.started) {
      return;
    }
    this.started = true;
    this.usePush = usePush = !(useHash = this.useHash = options.hashState || !options.pushState || !((_ref = this.history) != null ? _ref.pushState : void 0));
    if (usePush === true) {
      this.useHash = useHash = false;
    }
    if (options.forceRefresh || (useHash && !('onhashchange' in this.window))) {
      this.usePush = this.useHash = useHash = usePush = false;
    }
    this.intervalRate = options.interval || this.intervalRate;
    this.root = root = ("/" + (options.root || '/') + "/").replace(/^\/+|\/+$/g, '/');
    this.url = url = this.__getURL();
    location = this.location;
    atRoot = this.__atRoot();
    if (useHash && !atRoot) {
      root = root.slice(0, -1) || '/';
      this.location.replace("" + root + (this.__getPath()) + "#");
    } else if (usePush && atRoot) {
      this.set(this.__getHash(), {
        replace: true
      });
    }
    if (!usePush && !useHash && !options.forceRefresh) {
      frame = document.createElement('iframe');
      frame.src = 'javascript:0';
      frame.style.display = 'none';
      frame.tabIndex = -1;
      body = document.body;
      this.iframe = body.insertBefore(frame, body.firstChild).contentWindow;
      this.__setHash(this.iframe, "#" + url, false);
    }
    this.__toggleListeners();
    if (!options.silent) {
      return this.triggerEvent('changed', this.url);
    }
  };


  /*
   Stop tweak.History. Most likely useful for a web component that uses the history to change state,
   but if removed from page then component may want to stop the history.
   */

  History.prototype.stop = function() {
    this.__toggleListeners('off');
    return this.started = false;
  };


  /*
    Set the URL and add the URL to history.
    
    @param [Object] options An optional object to pass in optional arguments.
    @option options [Boolean] replace (default = false) Specify whether to replace the current item in the history.
    @option options [Boolean] silent (default = true) Specify whether to allow triggering of event when setting the URL.
  
    @example Setting the History (updating the URL).
      tweak.History.set('/#/fake/url');
  
    @example Replacing the last History state (updating the URL).
      tweak.History.set('/#/fake/url', {
        replace:true
      });
  
    @example Setting the History (updating the URL) and calling history change event.
      tweak.History.set('/#/fake/url', {
        silent:false
      });
   */

  History.prototype.set = function(url, options) {
    var fullUrl, replace, root;
    if (options == null) {
      options = {};
    }
    if (!this.started) {
      return;
    }
    if (options.silent == null) {
      options.silent = true;
    }
    replace = options.replace;
    url = this.__getURL(url) || '';
    root = this.root;
    if (url === '' || url.charAt(0) === '?') {
      root = root.slice(0, -1) || '/';
    }
    fullUrl = "" + root + url;
    url = decodeURI(url.replace(/#.*$/, ''));
    if (this.url === url) {
      return;
    }
    this.url = url;
    if (this.usePush) {
      this.history[replace ? 'replaceState' : 'pushState']({}, document.title, fullUrl);
    } else if (this.useHash) {
      this.__setHash(this.window, url, replace);
      if (this.iframe && url !== this.__getHash(this.iframe)) {
        this.__setHash(this.iframe, url, replace);
      }
    } else {
      this.location.assign(fullURL);
      return;
    }
    if (!options.silent) {
      this.triggerEvent('changed', this.url = url);
    }
  };


  /*
    @private
    Add listeners of remove history change listeners.
    @param [String] prefix (Default = 'on') Set the prefix - 'on' or 'off'.
   */

  History.prototype.__toggleListeners = function(prefix) {
    if (prefix == null) {
      prefix = 'on';
    }
    if (this.pushState) {
      tweak.Common[prefix](this.window, 'popstate', this.__checkChanged);
    } else if (this.useHash && !this.iframe) {
      tweak.Common[prefix](this.window, 'hashchange', this.__checkChanged);
    } else if (this.useHash) {
      if (prefix === 'on') {
        this.__interval = setInterval(this.__checkChanged, this.intervalRate);
      } else {
        clearInterval(this.__interval);
        document.body.removeChild(this.iframe.frameElement);
        this.iframe = this.__interval = null;
      }
    }
  };


  /*
    @private
    Gets whether the URL is at the root of application.
    @return Gets whether the URL is at the root of application.
   */

  History.prototype.__atRoot = function() {
    var path;
    path = this.location.pathname.replace(/[^\/]$/, '$&/');
    return path === this.root && !this.__getSearch();
  };


  /*
    @private
    Get the URL formatted without the hash.
    @param [Window] window The window to retrieve hash.
    @return Normalized URL without hash.
   */

  History.prototype.__getHash = function(window) {
    var match;
    match = (window || this).location.href.match(/#(.*)$/);
    if (match) {
      return match[1];
    } else {
      return '';
    }
  };


  /*
    @private
    In IE6 the search and hash are wrong when it contains a question mark.
    @return search if it matches or return empty string.
   */

  History.prototype.__getSearch = function() {
    var match;
    match = this.location.href.replace(/#.*/, '').match(/\?.+/);
    if (match) {
      return match[0];
    } else {
      return '';
    }
  };


  /*
    @private
    Get the pathname and search parameters, without the root.
    @return Normalized URL.
   */

  History.prototype.__getPath = function() {
    var path, root;
    path = decodeURI("" + this.location.pathname + (this.__getSearch()));
    root = this.root.slice(0, -1);
    if (!path.indexOf(root)) {
      path = path.slice(root.length);
    }
    if (path.charAt(0) === '/') {
      return path.slice(1);
    } else {
      return path;
    }
  };


  /*
    @private
    Get a normalized URL.
    @param [String] URL The URL to normalize - if null then URL will be retrieved from window.location.
    @param [Boolean] force Force the returning value to be hash state.
    @return Normalized URL without trailing slashes at either side.
   */

  History.prototype.__getURL = function(url, force) {
    var root;
    if (url == null) {
      if (this.usePush || force) {
        url = decodeURI("" + this.location.pathname + this.location.search);
        root = this.root.replace(/\/$/, '');
        if (!url.indexOf(root)) {
          url = url.slice(root.length);
        }
      } else {
        url = this.__getHash();
      }
    }
    url.replace(/^\/+/g, '/');
    return url.replace(/^\/+$/g, '');
  };


  /*
    @private
    Change the hash or replace the hash.
    @param [Location] location The location to amend the hash to. ieFrame.location or the window.location.
    @param [String] URL The URL to replace the current hash with.
    @param [Boolean] replace Whether to replace the hash by href or to change hash directly.
   */

  History.prototype.__setHash = function(window, url, replace) {
    if (this.iframe === window) {
      window.document.open().close();
    }
    if (replace) {
      window.location.replace("" + (location.href.replace(/(javascript:|#).*$/, '')) + "#" + url);
    } else {
      window.location.hash = "" + url;
    }
  };


  /*
    @private
    Check whether the URL has been changed, if it has then trigger change event.
   */

  History.prototype.__checkChanged = function() {
    var now, old;
    now = this.__getURL();
    old = this.url;
    if (now === old) {
      if (this.iframe) {
        now = this.__getHash(this.iframe);
        this.set(now);
      } else {
        return false;
      }
    }
    this.triggerEvent('changed', this.url = now);
    return true;
  };

  return History;

})(tweak.Events);

tweak.History = new tweak.History();

    })(window); 

;;
(function(window){
    
/*
  Web applications often provide linkable, bookmark, shareable URLs for important
  locations in the application. The Router module provides methods for routing to
  events which can control the application. Traditionally it used to be that
  routers worked from hash fragments (#page/22). However, the HTML5 History API now
  provides standard URL formats (/page/22). Routers provide functionality that
  links applications/components/modules together through data passed through the URL.

  The router's routes can be formatted as a string that provides additional easy
  management to routing of events. A route can contain the following structure.
  Which implements splats, parameters and optional parameters.
  
  @example Route with parameters
    Adding a route ':section:page' or ':section/:page' attached to the event of 'navigation', will trigger a
    'navigation' event and pass the following data with a similar HashState of '/#/5/93'.
    {
      url:'/5/93',
      data:{
        section:'5',
        page:'93'
      }
    }
  
  @example Route with parameters one being optional
    Adding a optional parameter route ':section?page' or ':section/?page' attached to the event of 'navigation',
    will trigger a 'navigation' event and pass the following data with a similar HashState of '/#/5/6'.
    {
      url:'/5/6',
      data:{
        section:'5',
        page:'6'
      }
    }

    Adding a optional parameter route ':section?page' or ':section/?page' attached to the event of 'navigation',
    will trigger a 'navigation' event and pass the following data with a similar HashState of '/#/5'.
    {
      url:'/5',
      data:{
        section:'5'
      }
    }
  
  @example Route with splat
    Adding a splat route ':section:page/*' or ':section/:page/*' attached to the event of 'navigation', will
    trigger a 'navigation' event and pass the following data with a similar HashState of '/#/5/6/www.example.com'.
    {
      url:'/5/6/www.example.com',
      data:{
        section:'5',
        page:'6',
        splat:'www.example.com'
      }
    }
  
  @example URL with query string
    When you want to use URLs that contain a query string, '/blog?id=9836384&light&reply=false', then the data
    sent back to an event will look like:
    {
      url:'/blog?id=9836384&light&reply=false',
      data:{
        blog:{
          id:9836384,
          light:'true',
          reply:'false'
        }
      }
    }

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
 */
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

tweak.Router = (function(_super) {
  var __getKeys, __getQueryData, __paramReg, __toRegex;

  __extends(Router, _super);

  Router.prototype.uid = 0;

  Router.prototype["super"] = tweak["super"];


  /*
    The constructor initialises the routers unique ID, routes, and event listening.
    
    @param [object] routes (optional, default = {}) An object containing event name based keys to an array of routes.
  
    @example Creating a Router with a set of predefined routes.
      var router;
      router = new tweak.Router({
        'navigation':[
          ':section/:page',
          /:website/:section/?page
        ],
        'demo':[
          ':splat/:example/*'
        ]
      });
   */

  function Router(routes) {
    this.routes = routes != null ? routes : {};
    this.uid = "r_" + (tweak.uids.r++);
    tweak.History.addEvent('changed', this.__urlChanged, this);
  }


  /*
    Add a route to the Router.
    @param [String] event The event name to add route to.
    @param [String, Reg-ex] route A string or Reg-ex formatted string or Reg-ex.
  
    @example Adding a single string formatted route to an event.
      var router;
      router = new tweak.Router();
      router.add('navigation', '/:section/:page');
  
    @example Adding a single Reg-ex formatted route to an event.
      var router;
      router = new tweak.Router();
      router.add('navigation', /^(*.)$/);
   */

  Router.prototype.add = function(event, route) {
    if (this.routes[event] != null) {
      this.routes[event].push(route);
    } else {
      this.routes[event] = [route];
    }
  };


  /*
    @overload remove(event, route)
      Remove a single string formatted route from an event.
      @param [String] event The event name to add route to.
      @param [String] route A string formatted string. (':section/:page')
  
    @overload remove(event, route)
      Remove a string containing multiple string formatted routes from an event.
      @param [String] event The event name to add route to.
      @param [String] route A string containing multiple string formatted routes. (':section/:page :section/:page/*')
  
    @overload remove(event, route)
      Remove a single Reg-ex formatted route from an event.
      @param [String] event The event name to add route to.
      @param [Boolean] route A Reg-ex formatted route. (/^.*$/)
    
    @example Removing a single string formatted route from an event
      var router;
      router = new tweak.Router();
      router.remove('navigation', '/:section/:page');
  
    @example Removing a multiple string formatted routes from an event.
      var router;
      router = new tweak.Router();
      router.remove('navigation', '/:section/:page /:website/:section/?page');
  
    @example Removing a single Reg-ex formatted route from an event.
      var router;
      router = new tweak.Router();
      router.remove('navigation', /^(*.)$/);
   */

  Router.prototype.remove = function(event, routes) {
    var key, route, routers, _i, _len, _ref;
    routers = this.routes[event];
    if (typeof routes === 'string') {
      _ref = (" " + (routes.replace(/\s+/g, ' ')) + " ").split(' ');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        route = _ref[_i];
        routers = (" " + (routers.join(' ')) + " ").split(" " + route + " ");
      }
    } else {
      for (key in routers) {
        route = routers[key];
        if (route === routes) {
          delete routers[key];
        }
      }
    }
    this.routes[event] = routers;
    if ((routers != null) && ((routes == null) || routers.length === 0)) {
      delete this.routes[event];
    }
  };


  /*
    @private
    Reg-ex to get parameters from a URL.
   */

  __paramReg = /\/?[?:]([^?\/:]*)/g;


  /*
    @private
    Checks URL segment to see if it can extract additional data when formatted like a query string.
    @param [String] segment The URL segment to extract additional data when formatted as a query string.
    @return [Object, String] Extracted data of given segment parameter.
   */

  __getQueryData = function(segment) {
    var key, option, params, prop, props, query, _i, _len;
    query = /^.*\?(.+)/.exec(segment);
    if (query) {
      params = /([^&]+)&*/.exec(query[1]);
      if (params) {
        for (_i = 0, _len = params.length; _i < _len; _i++) {
          option = params[_i];
          segment = {};
          props = /(.+)[:=]+(.+)|(.+)/.exec(segment);
          if (props) {
            key = props[3] || props[1];
            prop = props[2] || 'true';
            segment[key] = prop;
          }
        }
      }
    } else if (segment) {
      segment = segment.replace(/\?/g, '');
    }
    return segment;
  };


  /*
    @private
    Converts a string formatted route into its Reg-ex counterpart.
    @param [String] route The route to convert into a Reg-ex formatted route.
    @return [Reg-ex] The Reg-ex formatted route of given string formatted route.
   */

  __toRegex = function(route) {
    var escapeReg, splatReg;
    escapeReg = /[\-\\\^\[\]\s{}+.,$|#]/g;
    splatReg = /\/?(\*)$/;
    route = route.replace(escapeReg, '\\$&');
    route = route.replace(__paramReg, function(match) {
      var res;
      res = '\\/?([^\\/]*?)';
      if (/^\/?\?/.exec(match)) {
        return "(?:" + res + ")?";
      } else {
        return res;
      }
    });
    route = route.replace(splatReg, '\\/?(.*?)');
    return new RegExp("^" + route + "[\\/\\s]?$");
  };


  /*
    @private
    Get the parameter keys from a string formatted route to use as the data passed to event.
    @param [String] route The string formatted route to get parameter keys from.
   */

  __getKeys = function(route) {
    var res;
    res = route.match(__paramReg) || [];
    res.push('splat');
    return res;
  };


  /*
    @private
    When history event is made this method is called to check this Routers events to see if any route events can be triggered.
    @param [String] url A URL to check route events to.
    @event {event_name} Triggers a route event with passed in data from URL.
   */

  Router.prototype.__urlChanged = function(url) {
    var event, item, key, keys, match, res, route, routes, _ref, _results;
    url = url.replace(/^\/+|\/+$/g, '');
    _ref = this.routes;
    _results = [];
    for (event in _ref) {
      routes = _ref[event];
      _results.push((function() {
        var _i, _j, _len, _len1, _ref1, _results1;
        _results1 = [];
        for (_i = 0, _len = routes.length; _i < _len; _i++) {
          route = routes[_i];
          keys = [];
          if (typeof route === 'string') {
            keys = __getKeys(route);
            route = __toRegex(route);
          }
          if (match = route.exec(url)) {
            res = {
              url: url,
              data: {}
            };
            match.splice(0, 1);
            key = 0;
            for (_j = 0, _len1 = match.length; _j < _len1; _j++) {
              item = match[_j];
              res.data[((_ref1 = keys[key]) != null ? _ref1.replace(/^[?:\/]*/, '') : void 0) || key] = __getQueryData(item);
              key++;
            }
            _results1.push(this.triggerEvent(event, res));
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  return Router;

})(tweak.Events);

    })(window); 

;;
(function(window){
    
/*
  The future of MVC doesn't always lie in web applications; the architecture to
  TweakJS allows for integration of components anywhere on a website. For example
  you can plug "Web Components" into your static site; like sliders, accordions.
  The flexibility is endless; allowing MVC to be used from small web components
  to full scale one page web applications.

  TweakJS wraps its Models, Views, Templates, and Controllers into a Component
  module. The Component module acts intelligently to build up your application
  with simple configuration files. Each Component its built through a config
  object; this allows for powerful configuration with tonnes of flexibility.
  The config objects are extremely handy for making Components reusable, with
  easy accessible configuration settings.

  Each Component can have sub Components which are accessible in both directions;
  although it is recommended to keep functionality separate it sometimes comes in
  handy to have access to other parts of the application. Each Component can
  extend another Component, which will then inherent the models, views, templates,
  and controllers directly from that Component. If you however want to extend a
  Component using a different Model you can simply overwrite that model, or extend
  the functionality to the inherited model Components model.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
 */
var __slice = [].slice;

tweak.Component = (function() {
  Component.prototype.model = null;

  Component.prototype.view = null;

  Component.prototype.components = null;

  Component.prototype.controller = null;

  Component.prototype.router = null;

  Component.prototype.uid = 0;

  Component.prototype.require = tweak.Common.require;

  Component.prototype.clone = tweak.Common.clone;

  Component.prototype.combine = tweak.Common.combine;

  Component.prototype.findModule = tweak.Common.findModule;

  Component.prototype.relToAbs = tweak.Common.relToAbs;

  Component.prototype.parse = tweak.Common.parse;

  Component.prototype["super"] = tweak["super"];

  Component.prototype.modules = ['controller', 'model', 'view', 'router', 'components'];


  /*
    @param [Object] relation Relation to the Component.
    @param [Object] options Configuration for the Component.
   */

  function Component(relation, options) {
    var name, name2, prop, prop2, _i, _j, _len, _len1, _ref, _ref1;
    if (options == null) {
      throw new Error('No options given');
    }
    this.uid = "c_" + (tweak.uids.c++);
    relation = this.relation = relation === window ? {} : relation;
    if (relation.relation == null) {
      relation.relation = {};
    }
    this.parent = relation instanceof tweak.Component ? relation : relation.component || relation;
    this.root = this.parent.root || this;
    this.name = options.name;
    if (this.name == null) {
      throw new Error('No name given');
    }
    options.name = this.name = this.relToAbs(this.parent.name || '', this.name);
    this.config = this.__buildConfig(options) || {};
    if (this.config.router) {
      this.__addRouter();
    }
    this.__addModel();
    this.__addView();
    this.__addComponents();
    this.__addController();
    _ref = this.modules;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      name = _ref[_i];
      if (!(prop = this[name])) {
        continue;
      }
      prop.parent = this.parent;
      prop.component = this;
      _ref1 = this.modules;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        name2 = _ref1[_j];
        if (name !== name2 && (prop2 = this[name2])) {
          prop[name2] = prop2;
        }
      }
    }
  }


  /*
    When the component is initialised it's modules are also initialised.
   */

  Component.prototype.init = function() {
    var item, name, _i, _len, _ref;
    _ref = this.modules;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      name = _ref[_i];
      if (name !== 'view' && (item = this[name])) {
        if (typeof item.init === "function") {
          item.init();
        }
      }
    }
  };


  /*
    @private
    Builds the configuration object for the Component.
    @param [Object] options Component options.
    @return [Object] Combined config based on the components inheritance.
   */

  Component.prototype.__buildConfig = function(options) {
    var configs, extension, i, name, paths, requested, result, strict, _i, _ref, _ref1;
    configs = [];
    paths = this.paths = [];
    extension = this.name;
    if (options) {
      strict = options.strict != null ? options.strict : options.strict = true;
      configs.push(this.clone(options));
      if (options["extends"]) {
        extension = options["extends"];
      }
    }
    name = ((_ref = this.parent) != null ? _ref.name : void 0) || this.name;
    while (extension) {
      requested = this.require(name, "" + extension + "/config", strict ? null : {});
      paths.push(this.relToAbs(name, extension));
      configs.push(this.clone(requested));
      extension = requested["extends"];
    }
    this.names = paths;
    if (this.names.indexOf(this.name === -1)) {
      this.names.unshift(this.name);
    }
    result = configs[configs.length - 1];
    for (i = _i = _ref1 = configs.length - 2; _ref1 <= 0 ? _i <= 0 : _i >= 0; i = _ref1 <= 0 ? ++_i : --_i) {
      result = this.combine(result, configs[i]);
    }
    if (result.model == null) {
      result.model = {};
    }
    if (result.view == null) {
      result.view = {};
    }
    if (result.controller == null) {
      result.controller = {};
    }
    if (result.components == null) {
      result.components = [];
    }
    if (result.events == null) {
      result.events = {};
    }
    return result;
  };


  /*
    @private
    Add a module to the Component, if module can't be found then it will use a surrogate object.
    @param [String] name Name of the module.
    @param [Object] surrogate Surrogate if the module can not be found.
    @param [...] params Parameters passed into the module on construction.
   */

  Component.prototype.__addModule = function() {
    var Module, module, name, params, surrogate;
    name = arguments[0], surrogate = arguments[1], params = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    Module = this.findModule(this.paths, "./" + name, surrogate);
    module = this[name] = (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(Module, [this.config[name]].concat(__slice.call(params)), function(){});
    module.component = this;
    module.root = this.root;
  };


  /*
    @private
    Short cut method to adding view using the addModule method.
    @param [...] params Parameters passed to into the view constructor.
   */

  Component.prototype.__addView = function() {
    var params;
    params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this.__addModule.apply(this, ['view', tweak.View].concat(__slice.call(params)));
  };


  /*
    @private
    Short cut method to adding Model using the addModule method.
    @param [...] params Parameters passed to into the model constructor.
   */

  Component.prototype.__addModel = function() {
    var params;
    params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this.__addModule.apply(this, ['model', tweak.Model].concat(__slice.call(params)));
  };


  /*
    @private
    Short cut method to adding controller using the addModule method.
    @param [...] params Parameters passed to into the controller constructor.
   */

  Component.prototype.__addController = function() {
    var params;
    params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this.__addModule.apply(this, ['controller', tweak.Controller].concat(__slice.call(params)));
  };


  /*
    @private
    Add module to this Component.
    @param [...] params Parameters passed to into the Components constructor.
   */

  Component.prototype.__addComponents = function() {
    var Module, module, name;
    name = 'components';
    Module = this.findModule(this.paths, "./" + name, tweak.Components);
    module = this[name] = new Module(this, this.config[name]);
  };


  /*
    @private
    Short cut method to adding router using the addModule method.
    @param [...] params Parameters passed to into the router constructor.
   */

  Component.prototype.__addRouter = function() {
    var params;
    params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this.__addModule.apply(this, ['router', tweak.Router].concat(__slice.call(params)));
  };


  /*
    @private
    Reusable method to render and re-render.
    @param [String] type The type of rendering to do either 'render' or 'rerender'.
   */

  Component.prototype.__componentRender = function(type) {
    this.view.addEvent("" + type + "ed", function() {
      this.components.addEvent('ready', function() {
        return this.controller.triggerEvent('ready');
      }, this, 1);
      return this.components[type]();
    }, this, 1);
    this.view[type]();
  };


  /*
    Renders itself and its subcomponents.
    @event ready Triggers ready event when itself and its Components are ready/rendered.
   */

  Component.prototype.render = function() {
    var name;
    name = this.name;
    this.__componentRender('render');
  };


  /*
    Re-renders itself and its subcomponents.
    @event ready Triggers ready event when itself and its Components are ready/re-rendered.
   */

  Component.prototype.rerender = function() {
    this.__componentRender('rerender');
  };


  /*
    Destroy this Component. It will clear the view if it exists; and removes it from the Components Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
   */

  Component.prototype.destroy = function(silent) {
    var components, i, item, _i, _len, _ref;
    this.view.clear();
    components = this.relation.components;
    if (components != null) {
      i = 0;
      _ref = components.data;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        if (item.uid === this.uid) {
          components.remove(i, silent);
          return;
        }
        i++;
      }
    }
  };


  /*
    Short-cut to the controllers findEvent method.
  
    @overload findEvent(names, build)
      Find events on controller with a space separated string.
      @param [String] names The event name(s); split on a space.
      @param [Boolean] build (Default = false) Whether or not to add an event object to the controller when none can be found.
      @return [Array<Event>] All event objects that are found/created then it is returned in an Array.
  
    @overload findEvent(names, build)
      Find events on controller with an array of names (strings).
      @param [Array<String>] names An array of names (strings).
      @param [Boolean] build (Default = false) Whether or not to add an event object to the controller when none can be found.
      @return [Array<Event>] All the controllers event objects that are found/created then it is returned in an Array.
   */

  Component.prototype.findEvent = function(names, build) {
    return this.controller.findEvent(names, build);
  };


  /*
    Short-cut to the controllers addEvent method.
  
    @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
    @param [Function] callback The event callback function.
    @param [Number] maximum (Default = null). The maximum calls on the event listener. After the total calls the events callback will not invoke.
    @param [Object] context The contextual object of which the event to be bound to.
   */

  Component.prototype.addEvent = function(names, callback, max, context) {
    return this.controller.addEvent(names, callback, max, context);
  };


  /*
    Short cut to the controllers removeEvent method.
  
    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Function] callback (optional) The callback function of the event. If no specific callbacki s given then all the controller events under event name are removed.
    @param [Object] context (default = this) The contextual object of which the event is bound to. If this matches then it will be removed, however if set to null then all events no matter of context will be removed.
   */

  Component.prototype.removeEvent = function(names, callback, context) {
    return this.controller.removeEvent(names, callback, context);
  };


  /*
    Short cut to the controllers triggerEvent method.
  
    @overload triggerEvent(names, params)
      Trigger events on controller by name only.
      @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @param [...] params Parameters to pass into the callback function.
  
    @overload triggerEvent(options, params)
      Trigger events on controller by name and context.
      @param [Object] options Options and limiters to check against callbacks.
      @param [...] params Parameters to pass into the callback function.
      @option options [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @option options [Context] context (Default = null) The context of the callback to check against a callback.
   */

  Component.prototype.triggerEvent = function() {
    var names, params, _ref;
    names = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return (_ref = this.controller).triggerEvent.apply(_ref, [names].concat(__slice.call(params)));
  };


  /*
    Shortcut to the controllers updateEvent method.
  
    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Object] options Optional limiters and update values.
    @option options [Object] context The contextual object to limit updating events to.
    @option options [Function] callback Callback function to limit updating events to.
    @option options [Number] max Set a new maximum calls to an event.
    @option options [Number] calls Set the amount of calls that has been triggered on this event.
    @option options [Boolean] reset (Default = false) If true then calls on an event get set back to 0.
    @option options [Boolean] listen Whether to enable or disable listening to event.
   */

  Component.prototype.updateEvent = function(names, options) {
    return this.controller.updateEvent(names, options);
  };


  /*
    Resets the controllers events to empty.
   */

  Component.prototype.resetEvents = function() {
    return this.controller.resetEvents();
  };


  /*
    This method is used to extract all data of a component. If there is an export method within the Component Controller
    then the Controller export method will be executed with the data returned from the method.
    @param [Object] limit Limit the data from model to be exported
    @return [Object] Extracted data from Component.
   */

  Component.prototype["export"] = function(limit) {
    var _base;
    return (typeof (_base = this.controller)["export"] === "function" ? _base["export"]() : void 0) || {
      model: this.model["export"](limit, {
        components: this.components["export"]()
      })
    };
  };


  /*
    This method is used to import data into a component. If there is an import method within the Component Controller
    then the Controller import method will be executed with the data passed to the method.
    @param [Object] data Data to import to the Component.
    @option data [Object] model Object to import into the Component's Model.
    @option data [Array<Object>] components Array of Objects to import into the Component's Components.
   */

  Component.prototype["import"] = function(data) {
    if (this.controller["import"] != null) {
      return this.controller["import"](data);
    } else {
      if (data.model) {
        this.model["import"](data.model);
      }
      if (data.components) {
        return this.components["import"](data.components);
      }
    }
  };

  return Component;

})();

    })(window); 

;;
(function(window){
    
/*
  This class provides a collection of components. Upon initialisation components
  are dynamically built, from its configuration. The configuration for this
  component is an Array of component names (Strings). The component names are
  then used to create a component. Components nested within those components are
  then initialised creating a powerful scope of nest components that are completely
  unique to themselves.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
 */
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

tweak.Components = (function(_super) {
  __extends(Components, _super);

  Components.prototype._type = 'components';

  Components.prototype.relToAbs = tweak.Common.relToAbs;

  Components.prototype.splitMultiName = tweak.Common.splitMultiName;


  /*
    The constructor initialises the controllers unique ID, relating Component, its root and its initial configuration.
   */

  function Components(component, config) {
    this.component = component;
    this.config = config != null ? config : [];
    this.root = this.component.root;
    this.uid = "cp_" + (tweak.uids.cp++);
  }


  /*
   Construct the Collection with given options from the Components configuration.
   */

  Components.prototype.init = function() {
    var data, item, name, names, obj, path, prop, _i, _j, _k, _l, _len, _len1, _len2, _len3, _name, _ref;
    this.data = [];
    data = [];
    _name = this.component.name || this.config.name;
    _ref = this.config;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      obj = {};
      if (item instanceof Array) {
        names = this.splitMultiName(_name, item[0]);
        path = this.relToAbs(_name, item[1]);
        for (_j = 0, _len1 = names.length; _j < _len1; _j++) {
          name = names[_j];
          this.data.push(new tweak.Component(this, {
            name: name,
            "extends": path
          }));
        }
      } else if (typeof item === 'string') {
        data = this.splitMultiName(_name, item);
        for (_k = 0, _len2 = data.length; _k < _len2; _k++) {
          name = data[_k];
          this.data.push(new tweak.Component(this, {
            name: name
          }));
        }
      } else {
        obj = item;
        name = obj.name;
        data = this.splitMultiName(_name, name);
        obj["extends"] = this.relToAbs(_name, obj["extends"]);
        for (_l = 0, _len3 = data.length; _l < _len3; _l++) {
          prop = data[_l];
          obj.name = prop;
          this.data.push(new tweak.Component(this, obj));
        }
      }
      this.data[this.length++].init();
    }
  };


  /*
    @private
    Reusable method to render and re-render.
    @param [String] type The type of rendering to do either 'render' or 'rerender'.
   */

  Components.prototype.__componentRender = function(type) {
    var item, _i, _len, _ref;
    if (this.length === 0) {
      this.triggerEvent('ready');
    } else {
      this.total = 0;
      _ref = this.data;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        item.controller.addEvent('ready', function() {
          if (++this.total === this.length) {
            return this.triggerEvent('ready');
          }
        }, this, 1);
        item[type]();
      }
    }
  };


  /*
    Renders all of its Components.
    @event ready Triggers ready event when itself and its sub-Components are ready/rendered.
   */

  Components.prototype.render = function() {
    this.__componentRender('render');
  };


  /*
    Re-render all of its Components.
    @event ready Triggers ready event when itself and its sub-Components are ready/re-rendered.
   */

  Components.prototype.rerender = function() {
    this.__componentRender('rerender');
  };


  /*
    Find Component with matching data in model.
    @param [String] property The property to find matching value against.
    @param [*] value Data to compare to.
    @return [Array] An array of matching Components.
   */

  Components.prototype.whereData = function(property, value) {
    var collectionKey, componentData, data, key, modelData, prop, result;
    result = [];
    componentData = this.data;
    for (collectionKey in componentData) {
      data = componentData[collectionKey];
      modelData = data.model.data || model.data;
      for (key in modelData) {
        prop = modelData[key];
        if (key === property && prop === value) {
          result.push(data);
        }
      }
    }
    return result;
  };


  /*
    Reset this Collection of components. Also destroys it's components (views removed from DOM).
    @event changed Triggers a generic event that the store has been updated.
   */

  Components.prototype.reset = function() {
    var item, _i, _len, _ref;
    _ref = this.data;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      item.destroy();
    }
    Components.__super__.reset.call(this);
  };

  return Components;

})(tweak.Collection);

    })(window); 

;
//# sourceMappingURL=tweak.js.map