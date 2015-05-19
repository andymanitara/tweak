;
(function(window){
    
/*
  tweak.view.html.js 1.3.0

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
 */
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

tweak.Viewable = {
  width: window.innerWidth || (document.documentElement || document.documentElement.getElementsByTagName('body')[0]).clientWidth,
  height: window.innerHeight || (document.documentElement || document.documentElement.getElementsByTagName('body')[0]).clientHeight
};


/*
  This class extends the View class, extending its rendering functionality for HTML.
  The ViewHTML class does not provide functionality to manipulate this Views
  presentation layer. To extend the HTMLView to provide extra functionality to
  manipulate this View's rendered interface (DOM) please include the optional
  tweak.ViewHTMLAdvanced class.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
 */

tweak.ViewHTML = (function(_super) {
  __extends(ViewHTML, _super);

  function ViewHTML() {
    return ViewHTML.__super__.constructor.apply(this, arguments);
  }

  ViewHTML.prototype.require = tweak.Common.require;

  ViewHTML.prototype.splitMultiName = tweak.Common.splitMultiName;

  ViewHTML.prototype.relToAbs = tweak.Common.relToAbs;

  ViewHTML.prototype.findModule = tweak.Common.findModule;


  /*
    Default initialiser function - called when the View has rendered
   */

  ViewHTML.prototype.init = function() {};


  /*
    Renders the View, using a html template engine. The View is loaded asynchronously, this prevents the DOM from
    from congesting during rendering. The View won't be rendered until its parent View is rendered and any other
    components Views that are waiting to be rendered; this makes sure that components are rendered into in there
    correct positions.
    
    @param [Boolean] silent (Optional, default = false) If true events are not triggered upon any changes.
    @event rendered The event is called when the View has been rendered.
   */

  ViewHTML.prototype.render = function(silent) {
    var classNames, config, name, rendered, template;
    if (this.isRendered() && !silent) {
      this.triggerEvent('rendered');
      return;
    }
    if (this.model == null) {
      throw new Error('No model attached to View');
    }
    config = this.config;
    if (config.attach == null) {
      config.attach = {};
    }
    this.name = this.component.name || this.config.name || this.uid;
    classNames = (function() {
      var _i, _len, _ref, _results;
      _ref = this.component.names;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        _results.push(name.replace(/[\/\\]/g, '-'));
      }
      return _results;
    }).call(this);
    template = config.template ? this.require(this.name, config.template) : this.findModule(this.component.paths, './template');
    template = template(this.model.data);
    rendered = (function(_this) {
      return function(template) {
        var attachTo, attachment, html, parent, strip, _ref, _ref1, _ref2, _ref3;
        attachTo = ((_ref = _this.config.attach) != null ? _ref.to : void 0) || ((_ref1 = _this.config.attach) != null ? _ref1.name : void 0) || _this.name;
        parent = (_ref2 = _this.component.parent) != null ? (_ref3 = _ref2.view) != null ? _ref3.el : void 0 : void 0;
        html = document.documentElement;
        attachment = attachTo.tagName ? attachTo : _this.getAttachmentNode(parent) || _this.getAttachmentNode(html) || parent || html;
        _this.el = _this.attach(attachment, template, config.attach.method);
        strip = /^\s+|\s\s+|\s+$/;
        _this.addClass(_this.el, classNames.join(' '));
        _this.addID(_this.el, _this.uid);
        if (!silent) {
          _this.triggerEvent('rendered');
        }
        return _this.init();
      };
    })(this);
    this.createAsync(template, rendered);
  };


  /*
    Get the children nodes of an element.
    @param [DOMElement] parent The element to retrieve the children of
    @param [Boolean] recursive (Default: true) Whether to recursively go through its children's children to get a full list
    @return [Array<DOMElement>] Returns an array of children nodes inside an element
   */

  ViewHTML.prototype.getChildren = function(element, recursive) {
    var children, result;
    if (recursive == null) {
      recursive = true;
    }
    result = [];
    children = function(node) {
      var nodes, _i, _j, _len, _len1;
      if (node == null) {
        node = {};
      }
      nodes = node.children || [];
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        node = nodes[_i];
        result.push(node);
      }
      for (_j = 0, _len1 = nodes.length; _j < _len1; _j++) {
        node = nodes[_j];
        if (recursive && node.children) {
          children(node);
        }
      }
    };
    children(element);
    return result;
  };


  /*
    Clears the View and removed event listeners of DOM elements.
   */

  ViewHTML.prototype.clear = function(element) {
    if (element == null) {
      element = this.el;
    }
    if (element != null ? element.parentNode : void 0) {
      try {
        element.parentNode.removeChild(element);
        element = null;
      } catch (_error) {}
    }
  };


  /*
    Checks to see if the item is rendered; this is determined if the node has a parentNode.
    @return [Boolean] Returns whether the View has been rendered.
   */

  ViewHTML.prototype.isRendered = function() {
    if (document.documentElement.contains(this.el)) {
      return true;
    } else {
      return false;
    }
  };


  /*
    Get the attachment node for this element.
    @param [DOMElement] parent the DOM Element to search in
    @return [DOMElement] Returns the parent DOMElement.
   */

  ViewHTML.prototype.getAttachmentNode = function(parent) {
    var attachment, child, name, nodes, prop, val, _i, _j, _len, _len1, _ref, _ref1;
    if (!parent) {
      return;
    }
    name = ((_ref = this.config.attach) != null ? _ref.to : void 0) || this.name;
    nodes = this.getChildren(parent);
    nodes.unshift(parent);
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      prop = nodes[_i];
      if (child) {
        break;
      }
      attachment = prop.getAttribute('data-attach');
      if ((attachment != null) && !attachment.match(/\s+/)) {
        _ref1 = this.splitMultiName(this.component.parent.name || '', attachment);
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          val = _ref1[_j];
          if (name === val) {
            child = prop;
            break;
          }
        }
      }
    }
    return child;
  };


  /*
    Attach a DOMElement to another DOMElement. Attachment can happen by three methods, inserting before, inserting after, inserting at position and replacing.
  
    @param [DOMElement] parent DOMElement to attach to.
    @param [DOMElement] node DOMElement to attach to parent.
    @param [String, Number] method (Default = append) The method to attach ('prefix'/'before', 'replace', (number) = insert at position) any other method will use the attach method to insert after.
   */

  ViewHTML.prototype.attach = function(parent, node, method) {
    var e, item, num, _i, _len, _ref;
    switch (method) {
      case 'prefix':
      case 'before':
        parent.insertBefore(node, parent.firstChild);
        return parent.firstElementChild;
      case 'replace':
        _ref = parent.children;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          try {
            parent.removeChild(item);
          } catch (_error) {
            e = _error;
          }
        }
        parent.appendChild(node);
        return parent.firstElementChild;
      default:
        if (/^\d+$/.test("" + method)) {
          num = Number(method);
          parent.insertBefore(node, parent.children[num]);
          return parent.children[num];
        } else {
          parent.appendChild(node);
          return parent.lastElementChild;
        }
    }
  };


  /*
    Create an Element from a template string.
    
    @param [String] template A template String to parse to a DOMElement.
    @return [DOMElement] Parsed DOMElement.
   */

  ViewHTML.prototype.create = function(template) {
    var frag, temp;
    temp = document.createElement('div');
    frag = document.createDocumentFragment();
    temp.innerHTML = template;
    return temp.firstChild;
  };


  /*
    Asynchronously create an Element from a template string.
    
    @param [String] template A template String to parse to a DOMElement.
    @return [DOMElement] Parsed DOMElement.
   */

  ViewHTML.prototype.createAsync = function(template, callback) {
    return setTimeout((function(_this) {
      return function() {
        return callback(_this.create(template, 0));
      };
    })(this));
  };


  /*
    Select a DOMElement using a selector engine dependency affixed to the tweak.Selector object.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [DOMElement] root (Default = @el) The element root to search for elements with a selector engine.
    @return [Array<DOMElement>] An array of DOMElements.
  
    @throw When trying to use a selector engine without having one assigned to the tweak.Selector property you will
    receive the following error - "No selector engine defined to tweak.Selector"
   */

  ViewHTML.prototype.element = function(element, root) {
    if (root == null) {
      root = this.el;
    }
    if (typeof element === 'string') {
      if (tweak.Selector) {
        return tweak.Selector(element, root);
      } else {
        throw new Error('No selector engine defined to tweak.Selector');
      }
    } else {
      return [element];
    }
  };


  /*
    Apply event listener to element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
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

  ViewHTML.prototype.on = function() {
    var element, elements, item, params, _i, _len, _ref;
    element = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    elements = this.element(element || this.el);
    for (_i = 0, _len = elements.length; _i < _len; _i++) {
      item = elements[_i];
      (_ref = tweak.Common).on.apply(_ref, [item].concat(__slice.call(params)));
    }
  };


  /*
    Remove event listener to element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] type The type of event.
    @param [Function] callback The method to remove from the events callbacks
    @param [Boolean] capture (Default = false) Specifies whether the EventListener being
      removed was registered as a capturing listener or not. If a listener was registered
      twice, one with capture and one without, each must be removed separately. Removal of
      a capturing listener does not affect a non-capturing version of the same listener,
      and vice versa.
   */

  ViewHTML.prototype.off = function() {
    var element, elements, item, params, _i, _len, _ref;
    element = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    elements = this.element(element || this.el);
    for (_i = 0, _len = elements.length; _i < _len; _i++) {
      item = elements[_i];
      (_ref = tweak.Common).off.apply(_ref, [item].concat(__slice.call(params)));
    }
  };


  /*
    Trigger event listener on element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [Event, String] event Event to trigger or string if to create new event.
   */

  ViewHTML.prototype.trigger = function(element, event) {
    var elements, item, _i, _len;
    elements = this.element(element || this.el);
    for (_i = 0, _len = elements.length; _i < _len; _i++) {
      item = elements[_i];
      tweak.Common.trigger(item, event);
    }
  };


  /*
    Returns height of an element.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the of height an element.
   */

  ViewHTML.prototype.height = function(element) {
    return this.element(element)[0].offsetHeight;
  };


  /*
    Returns inside height of an element.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the of inside height an element.
   */

  ViewHTML.prototype.insideHeight = function(element) {
    return this.element(element)[0].clientHeight;
  };


  /*
    Returns width of an element.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the of width an element.
   */

  ViewHTML.prototype.width = function(element) {
    return this.element(element)[0].offsetWidth;
  };


  /*
    Returns inside width of an element.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the of inside width an element.
   */

  ViewHTML.prototype.insideWidth = function(element) {
    return this.element(element)[0].clientWidth;
  };


  /*
    Returns the offset from another element relative to another (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] from (default = "top") The direction to compare the offset.
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string representing a selector query if using a selector engine
    @return [Number] Returns the element offset value relative to another element.
   */

  ViewHTML.prototype.offsetFrom = function(element, from, relativeTo) {
    var elementBounds, relativeBounds;
    if (from == null) {
      from = 'top';
    }
    if (relativeTo == null) {
      relativeTo = document.getElementsByTagName('html')[0];
    }
    relativeTo = this.element(relativeTo)[0];
    element = this.element(element)[0];
    elementBounds = element.getBoundingClientRect();
    relativeBounds = relativeTo.getBoundingClientRect();
    return elementBounds[from] - relativeBounds[from];
  };


  /*
    Returns the top offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the top offset of an element relative to another element (or default to the body).
   */

  ViewHTML.prototype.offsetTop = function(element, relativeTo) {
    return this.offsetFrom(element, 'top', relativeTo);
  };


  /*
    Returns the bottom offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the bottom offset of an element relative to another element (or default to the body).
   */

  ViewHTML.prototype.offsetBottom = function(element, relativeTo) {
    return this.offsetFrom(element, 'bottom', relativeTo);
  };


  /*
    Returns the left offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the left offset of an element relative to another element (or default to the body).
   */

  ViewHTML.prototype.offsetLeft = function(element, relativeTo) {
    return this.offsetFrom(element, 'left', relativeTo);
  };


  /*
    Returns the right offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = window.document.body) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the right offset of an element relative to another element (or default to the body).
   */

  ViewHTML.prototype.offsetRight = function(element, relativeTo) {
    return this.offsetFrom(element, 'right', relativeTo);
  };


  /*
    @private
    Check if a elements attribute contains a string.
    @param [DOMElement, String] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] attribute A DOMElement attribute to check.
    @param [String] classes A string to check existance.
   */

  ViewHTML.prototype.hasInAttribute = function(element, attribute, item) {
    if ((" " + (this.element(element)[0][attribute]) + " ").indexOf(" " + item + " ") === -1) {
      return false;
    }
    return true;
  };


  /*
    Adjust an elements attribute by removing or adding to it.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] attribute A DOMElement attribute to adjust.
    @param [String] method The method of adjustment; add, remove and replace.
    @param [String] classes A string of names to adjust from the attribute of the element(s).
    @param [String] replacement (Optional) A string to pass as the replacement.
   */

  ViewHTML.prototype.adjust = function(element, attribute, method, classes, replacement) {
    var elements, i, item, name, prop, replacements, _i, _j, _len, _len1;
    elements = this.element(element);
    if (elements.length === 0) {
      return;
    }
    classes = (classes || '').split(/\s+/);
    if (typeof replacements !== "undefined" && replacements !== null) {
      replacements = replacements.split(/\s+/);
    }
    for (_i = 0, _len = elements.length; _i < _len; _i++) {
      item = elements[_i];
      if (item == null) {
        continue;
      }
      name = item[attribute];
      i = 0;
      for (_j = 0, _len1 = classes.length; _j < _len1; _j++) {
        prop = classes[_j];
        if (method === 'add') {
          if (!this.hasInAttribute(item, attribute, prop)) {
            name += " " + prop;
          }
        } else {
          if (prop === ' ') {
            continue;
          }
          if (method === 'remove') {
            name = (" " + name + " ").split(" " + prop + " ").join(' ');
          } else {
            name = !this.hasInAttribute(item, attribute, replacement) ? (" " + name + " ").split(" " + prop + " ").join(" " + replacement + " ") : (" " + name + " ").split(" " + prop + " ").join(' ');
          }
        }
        item[attribute] = name.replace(/\s{2,}/g, ' ').replace(/(^\s*|\s*$)/g, '');
      }
    }
  };


  /*
    Add a string of class names to the given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to add to the element(s).
   */

  ViewHTML.prototype.addClass = function(element, classes) {
    if (classes == null) {
      classes = '';
    }
    this.adjust(element, 'className', 'add', classes);
  };


  /*
    Remove a string of class names of the given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove to the element(s).
   */

  ViewHTML.prototype.removeClass = function(element, classes) {
    if (classes == null) {
      classes = '';
    }
    this.adjust(element, 'className', 'remove', classes);
  };


  /*
    Check of a string of class names is in then given element(s) className attribute.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove from the element(s).
   */

  ViewHTML.prototype.hasClass = function(element, name) {
    var elements, item, _i, _len;
    elements = this.element(element);
    if (elements.length === 0) {
      return;
    }
    for (_i = 0, _len = elements.length; _i < _len; _i++) {
      item = elements[_i];
      if (item == null) {
        continue;
      }
      if (!this.hasInAttribute(element, 'className', name)) {
        return false;
      }
    }
    return true;
  };


  /*
    Replace class name values in the given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to replace.
    @param [String] replacement The replacement string.
   */

  ViewHTML.prototype.replaceClass = function(element, classes, replacement) {
    this.adjust(element, 'className', 'replace', classes, replacement);
  };


  /*
    Add a string of ids to add to given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of ids to add to the given element(s).
   */

  ViewHTML.prototype.addID = function(element, ids) {
    if (ids == null) {
      ids = '';
    }
    this.adjust(element, 'id', 'add', ids);
  };


  /*
    Remove a string of ids from the given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] ids A string of ids to remove from the element(s).
   */

  ViewHTML.prototype.removeID = function(element, ids) {
    if (ids == null) {
      ids = '';
    }
    this.adjust(element, 'id', 'remove', ids);
  };


  /*
    Check of a string of class names is in given element(s) id attribute.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] ids A string of ids to check exists in the given element(s).
   */

  ViewHTML.prototype.hasID = function(element, name) {
    var elements, item, _i, _len;
    elements = this.element(element);
    if (elements.length === 0) {
      return;
    }
    for (_i = 0, _len = elements.length; _i < _len; _i++) {
      item = elements[_i];
      if (item == null) {
        continue;
      }
      if (!this.hasInAttribute(element, 'id', name)) {
        return false;
      }
    }
    return true;
  };


  /*
    Replace id values in the given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] ids A string of ids to replace.
    @param [String] replacement The replacement string.
   */

  ViewHTML.prototype.replaceID = function(element, ids, replacement) {
    this.adjust(element, 'id', 'replace', ids, replacement);
  };

  return ViewHTML;

})(tweak.View);

tweak.View = tweak.ViewHTML;

    })(window); 

;
//# sourceMappingURL=tweak.view.html.js.map