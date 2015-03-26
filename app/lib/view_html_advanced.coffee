###
  tweak.view.html.advanced.js 1.0.9

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###

###
  The Class it used to extend the ViewHTML Class with methods to manipulate the DOM.
  
  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
###
class tweak.ViewHTMLAdvanced extends tweak.ViewHTML
  ###
    Select a DOMElement using a selector engine dependency affixed to the tweak.Selector object.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [DOMElement] root (Default = @el) The element root to search for elements with a selector engine.
    @return [Array<DOMElement>] An array of DOMElements.

    @throw When trying to use a selector engine without having one assigned to the tweak.Selector property you will
    receive the following error - "No selector engine defined to tweak.Selector"
  ###
  element: (element, root = @el) ->
    if typeof element is 'string'
      if tweak.Selector
        tweak.Selector element, root
      else throw new Error "No selector engine defined to tweak.Selector"
    else [element]

  ###
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
  ###
  on: (element = @el, type, callback, capture = false) ->
    elements = @element element
    for item in elements
      tweak.Common.on item, type, callback, capture
    return

  ###
    Remove event listener to element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] type The type of event.
    @param [Function] callback The method to remove from the events callbacks
    @param [Boolean] capture (Default = false) Specifies whether the EventListener being
      removed was registered as a capturing listener or not. If a listener was registered
      twice, one with capture and one without, each must be removed separately. Removal of
      a capturing listener does not affect a non-capturing version of the same listener,
      and vice versa.
  ###
  off: (element = @el, type, callback, capture = false) ->
    elements = @element element
    for item in elements
      tweak.Common.off item, type, callback, capture
    return

  ###
    Trigger event listener on element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [Event, String] event Event to trigger or string if to create new event.
  ###
  trigger: (element = @el, event) ->
    elements = @element element
    for item in elements
      tweak.Common.trigger item, event
    return

  ###
    Returns height of an element.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the of height an element.
  ###
  height: (element) -> @element(element)[0].offsetHeight

  ###
    Returns inside height of an element.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the of inside height an element.
  ###
  insideHeight: (element) -> @element(element)[0].clientHeight

  ###
    Returns width of an element.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the of width an element.
  ###
  width: (element) -> @element(element)[0].offsetWidth

  ###
    Returns inside width of an element.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the of inside width an element.
  ###
  insideWidth: (element) -> @element(element)[0].clientWidth

  ###
    Returns the offset from another element relative to another (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] from (default = "top") The direction to compare the offset.
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string representing a selector query if using a selector engine
    @return [Number] Returns the element offset value relative to another element.
  ###
  offsetFrom:(element, from = "top", relativeTo) ->
    relativeTo ?= document.getElementsByTagName("html")[0]
    relativeTo = @element(relativeTo)[0]
    element = @element(element)[0]
    elementBounds = element.getBoundingClientRect()
    relativeBounds = relativeTo.getBoundingClientRect()
    elementBounds[from] - relativeBounds[from]
  
  ###
    Returns the top offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the top offset of an element relative to another element (or default to the body).
  ###
  offsetTop: (element, relativeTo) -> @offsetFrom element, "top", relativeTo

  ###
    Returns the bottom offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the bottom offset of an element relative to another element (or default to the body).
  ###
  offsetBottom: (element, relativeTo) -> @offsetFrom element, "bottom", relativeTo
  
  ###
    Returns the left offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the left offset of an element relative to another element (or default to the body).
  ###
  offsetLeft: (element, relativeTo) -> @offsetFrom element, "left", relativeTo
  
  ###
    Returns the right offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = window.document.body) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the right offset of an element relative to another element (or default to the body).
  ###
  offsetRight: (element, relativeTo) -> @offsetFrom element, "right", relativeTo

  ###
    @private
    Check of a string of class names is in an element(s) class.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove to the element(s).
  ###
  __has = (type, element, name) ->
    if (" #{element[type]} ").indexOf(" #{name} ") is -1 then return false
    true

  ###
    Add a string of class names to an element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes or ids to add to the element(s).
  ###
  adjust: (type, method, element, str, str2) ->
    elements = @element element
    if elements.length is 0 then return
    str = (str or '').split /\s+/
    if str2? then str2 = str2.split /\s+/
    else str2 = str
    for item in elements
      if not item? then continue
      i = 0
      for prop in str2
        name = item[type]
        if method is "add"
          if not __has type, item, prop then name += " #{prop}"
        else
          if prop is ' ' then continue
          if method is "remove"
            name = (" #{name} ").split(" #{prop} ").join ' '
          else
            name = (" #{name} ").split(" #{prop} ").join " #{str[i++]} "
        item[type] = name
          .replace /\s{2,}/g,' '
          .replace /(^\s*|\s*$)/g,''
    return

  ###
    Add a string of class names to an element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to add to the element(s).
  ###
  addClass: (element, classes = '') ->
    @adjust 'className', 'add', element, classes
    return

  ###
    Remove a string of class names of an element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove to the element(s).
  ###
  removeClass: (element, classes = '') ->
    @adjust 'className', 'remove', element, classes
    return
 
  ###
    Check of a string of class names is in an element(s) class.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove to the element(s).
  ###
  hasClass: (element, name) ->
    elements = @element element
    if elements.length is 0 then return
    for item in elements
      if not item? then continue
      if not __has 'className', element, name then return false
    true

  ###
    Replace of a string of class names in element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove to the element(s).
  ###
  replaceClass: (element, orig, classes) ->
    @adjust 'className', 'replace', element, classes, orig
    return

  ###
    Add a string of class names to an element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to add to the element(s).
  ###
  addID: (element, classes = '') ->
    @adjust 'id', 'add', element, classes
    return

  ###
    Remove a string of class names of an element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove to the element(s).
  ###
  removeID: (element, classes = '') ->
    @adjust 'id', 'remove', element, classes
    return
 
  ###
    Check of a string of class names is in an element(s) class.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove to the element(s).
  ###
  hasID: (element, name) ->
    elements = @element element
    if elements.length is 0 then return
    for item in elements
      if not item? then continue
      if not __has 'id', element, name then return false
    true
  ###
    Replace of a string of class names in element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove to the element(s).
  ###
  replaceID: (element, orig, classes) ->
    @adjust 'id', 'replace', element, classes, orig
    return

tweak.View = tweak.ViewHTMLAdvanced