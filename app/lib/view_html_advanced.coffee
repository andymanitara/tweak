###
  tweak.view.html.advanced.js 1.0.0

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###

###
  The view is the DOM controller. This should be used for code that doesnt really control any logic but how the view is displayed. For example animations.
  The view uses a templating engine to provide the html to the DOM.
  The view in common MV* frameworks is typically used to directly listen for model changes to rerender however typically this should be done in the controller.
  The data in the model is passed into the views template, allowing for easy manipulation of the view.
###
class tweak.ViewHTMLAdvanced extends tweak.ViewHTML
  # Not using own tweak.extends method as codo doesnt detect that this is an extending class
  
  ###
    Tweak has an optional dependecy of any selector engine in the tweak.Selector object
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [DOMElement] root (Default = @el) The element root to search for elements with a selector engine
    @return [Array<DOMElement>] Returns an array of DOMElements
    @throw When trying to use a selector engine without having one assigned to the tweak.Selector property you will recieve the following error - "Trying to get element with selector engine, but none defined to tweak.Selector"
  ###
  element: (element, root = @el) ->
    if typeof element is 'string'
      if tweak.Selector
        tweak.Selector element, root
      else throw new Error "Trying to get element with selector engine, but none defined to tweak.Selector"
    else [element]

  ###
    Apply event listener to element(s)
    @note Use the on method, which shortcuts to this if parameters match, or if performance is critical then you can skip a check and directly use this method.
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] type The type of event
    @param [Function] callback The method to apply to the event listener
    @param [Boolean] capture if true it indicates to initiate capture to the registered listener first.
  ###
  on: (element = @el, type, callback, capture = false) ->
    elements = @element element
    _callback = (e) -> _callback.fn e, _callback.targ
    _callback.fn = callback
    _callback.targ = element
    event = {type, callback, _callback, capture}
    for item in elements
      item._events ?= []
      item.addEventListener type, _callback, capture
      item._events.push event
    return
  ###
    Remove event listener to element(s)
    @note Use the off method, which shortcuts to this if parameters match, or if performance is critical then you can skip a check and directly use this method.
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] type The type of event
    @param [Boolean] capture If a listener was registered twice, one with capture and one without, each must be removed separately.
                            Removal of a capturing listener does not affect a non-capturing version of the same listener, and vice versa.
  ###
  off: (element = @el, type, callback, capture = false) ->
    elements = @element element
    for item in elements
      for evt in item._events or []
        if evt.type is type and evt.capture is capture and callback is evt.callback
          item.removeEventListener type, evt._callback, capture
    return

  ###
    Trigger event listener on element(s)
    @note Use the trigger method, which shortcuts to this if parameters match, or if performance is critical then you can skip a check and directly use this method.
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [Event] event an evet to trigger
  ###
  trigger: (element = @el, event) ->
    elements = @element element
    for item in elements
      item.dispatchEvent event
    return

  ###
    Returns height of an element
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the of height an element
  ###
  height: (element) -> @element(element)[0].offsetHeight

  ###
    Returns inside height of an element
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the of inside height an element
  ###
  insideHeight: (element) -> @element(element)[0].clientHeight

  ###
    Returns width of an element
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the of width an element
  ###
  width: (element) -> @element(element)[0].offsetWidth

  ###
    Returns inside width of an element
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the of inside width an element
  ###
  insideWidth: (element) -> @element(element)[0].clientWidth

  ###
    Returns the offset from another element relative to another (or default to the body)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] from (default = "top") The direction to compare the offset
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the element offset value relative to another element
  ###
  offsetFrom:(element, from = "top", relativeTo) ->
    relativeTo ?= document.getElementsByTagName("html")[0]
    relativeTo = @element(relativeTo)[0]
    element = @element(element)[0]
    elementBounds = element.getBoundingClientRect()
    relativeBounds = relativeTo.getBoundingClientRect()
    elementBounds[from] - relativeBounds[from]
  
  ###
    Returns the top offset of an element relative to another element (or default to the body)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the top offset of an element relative to another element (or default to the body)
  ###
  offsetTop: (element, relativeTo) -> @offsetFrom element, "top", relativeTo

  ###
    Returns the bottom offset of an element relative to another element (or default to the body)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the bottom offset of an element relative to another element (or default to the body)
  ###
  offsetBottom: (element, relativeTo) -> @offsetFrom element, "bottom", relativeTo
  
  ###
    Returns the left offset of an element relative to another element (or default to the body)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the left offset of an element relative to another element (or default to the body)
  ###
  offsetLeft: (element, relativeTo) -> @offsetFrom element, "left", relativeTo
  
  ###
    Returns the right offset of an element relative to another element (or default to the body)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String, DOMElement] relativeTo (default = window.document.body) A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the right offset of an element relative to another element (or default to the body)
  ###
  offsetRight: (element, relativeTo) -> @offsetFrom element, "right", relativeTo

  ###
    @private
    Split classes from a string to an array
  ###
  _splitString: _splitString = (str) ->
    results = []
    if typeof str isnt "string" then str = ''
    for key, prop of str.split /\s+/
      if prop isnt "" then results.push prop
    results

  
  ###
    @private
    Check of a string of class names is in an element(s) class
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to remove to the element(s)
  ###
  _has = (type, element, name) ->
    if (" #{element[type]} ").indexOf(" #{name} ") is -1 then return false
    true

  ###
    Add a string of class names to an element(s)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes or ids to add to the element(s)
  ###
  adjust: (type, method, element, str, str2) ->
    elements = @element element
    if elements.length is 0 then return
    str = _splitString str
    if str2? then str2 = _splitString str2
    else str2 = str
    for item in elements
      if not item? then continue      
      i = 0
      for prop in str2
        name = item[type]
        if method is "add"
          if not _has type, item, prop then name += " #{prop}"
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
    Add a string of class names to an element(s)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to add to the element(s)
  ###
  addClass: (element, classes = '') ->
    @adjust 'className', 'add', element, classes
    return

  ###
    Remove a string of class names of an element(s)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to remove to the element(s)
  ###
  removeClass: (element, classes = '') ->
    @adjust 'className', 'remove', element, classes
    return
 
  ###
    Check of a string of class names is in an element(s) class
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to remove to the element(s)
  ###
  hasClass: (element, name) ->
    elements = @element element
    if elements.length is 0 then return
    for item in elements
      if not item? then continue
      if not _has 'className', element, name then return false
    true


  ###
    Replace of a string of class names in element(s)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to remove to the element(s)
  ###
  replaceClass: (element, orig, classes) ->    
    @adjust 'className', 'replace', element, classes, orig
    return

  ###
    Add a string of class names to an element(s)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to add to the element(s)
  ###
  addID: (element, classes = '') ->
    @adjust 'id', 'add', element, classes
    return

  ###
    Remove a string of class names of an element(s)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to remove to the element(s)
  ###
  removeID: (element, classes = '') ->
    @adjust 'id', 'remove', element, classes
    return
 
  ###
    Check of a string of class names is in an element(s) class
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to remove to the element(s)
  ###
  hasID: (element, name) ->
    elements = @element element
    if elements.length is 0 then return
    for item in elements
      if not item? then continue
      if not _has 'id', element, name then return false
    true
  ###
    Replace of a string of class names in element(s)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to remove to the element(s)
  ###
  replaceID: (element, orig, classes) ->    
    @adjust 'id', 'replace', element, classes, orig
    return

tweak.View = tweak.ViewHTMLAdvanced