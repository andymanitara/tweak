###
  tweak.view.html.js 1.2.0

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###

tweak.Viewable =
  width: window.innerWidth or (document.documentElement or document.documentElement.getElementsByTagName('body')[0]).clientWidth
  height: window.innerHeight or (document.documentElement or document.documentElement.getElementsByTagName('body')[0]).clientHeight

###
  This class extends the View class, extending its rendering functionality for HTML.
  The ViewHTML class does not provide functionality to manipulate this Views
  presentation layer. To extend the HTMLView to provide extra functionality to
  manipulate this View's rendered interface (DOM) please include the optional
  tweak.ViewHTMLAdvanced class.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
###
class tweak.ViewHTML extends tweak.View
  # @property [Method] see tweak.Common.require
  require: tweak.Common.require
  # @property [Method] see tweak.Common.splitMultiName
  splitMultiName: tweak.Common.splitMultiName
  # @property [Method] see tweak.Common.relToAbs
  relToAbs: tweak.Common.relToAbs
  # @property [Method] see tweak.Common.findModule
  findModule: tweak.Common.findModule

  ###
    Default initialiser function - called when the View has rendered
  ###
  init: ->

  ###
    Renders the View, using a html template engine. The View is loaded asynchronously, this prevents the DOM from
    from congesting during rendering. The View won't be rendered until its parent View is rendered and any other
    components Views that are waiting to be rendered; this makes sure that components are rendered into in there
    correct positions.
    
    @param [Boolean] silent (Optional, default = false) If true events are not triggered upon any changes.
    @event rendered The event is called when the View has been rendered.
  ###
  render: (silent) ->
    if @isRendered() and not silent
      @triggerEvent 'rendered'
      return
      
    if not @model? then throw new Error 'No model attached to View'
    config = @config
    config.attach ?= {}

    @name = @component.name or @config.name or @uid
    
    # Makes sure that there is an id for this component set, either by the config or by its name
    classNames = for name in @component.names then name.replace /[\/\\]/g, '-'

    # Build the template with the date from the model
    template = if config.template then @require @name, config.template else @findModule @component.paths, './template'
    template = template @model.data
    
    # Create HTML element add add to DOM
    rendered = (template) =>
      # Attach template to the DOM and set @el
      attachTo = @config.attach?.to or @config.attach?.name or @name
      parent = @component.parent?.view?.el
      html = document.documentElement
      attachment = if attachTo.tagName then attachTo
      else @getAttachmentNode(parent) or @getAttachmentNode(html) or parent or html
      
      @el = @attach attachment, template, config.attach.method
        
      # Attempt to add class and uid
      strip = /^\s+|\s\s+|\s+$/
      @addClass @el, classNames.join ' '
      @addID @el, @uid

      if not silent then @triggerEvent 'rendered'
      @init()

    @createAsync template, rendered
    return

  ###
    Get the children nodes of an element.
    @param [DOMElement] parent The element to retrieve the children of
    @param [Boolean] recursive (Default: true) Whether to recursively go through its children's children to get a full list
    @return [Array<DOMElement>] Returns an array of children nodes inside an element
  ###
  getChildren: (element, recursive = true) ->
    result = []
    children = (node = {}) ->
      nodes = node.children or []
      for node in nodes
        result.push node
      for node in nodes
        if recursive and node.children then children node
      return
    # Iterate though all children of an element
    children element
    result

  ###
    Clears the View and removed event listeners of DOM elements.
  ###
  clear: (element = @el) ->
    if element?.parentNode
      try
        element.parentNode.removeChild element
        element = null
    return

  ###
    Checks to see if the item is rendered; this is determined if the node has a parentNode.
    @return [Boolean] Returns whether the View has been rendered.
  ###
  isRendered: -> if document.documentElement.contains @el then true else false
  
  ###
    Get the attachment node for this element.
    @param [DOMElement] parent the DOM Element to search in
    @return [DOMElement] Returns the parent DOMElement.
  ###
  getAttachmentNode: (parent) ->
    if not parent then return
    # The result is the parent el, or it will try to find a node to attach to in the DOM
    name = @config.attach?.to or @name
    nodes = @getChildren parent
    nodes.unshift parent
    for prop in nodes
      if child then break
      attachment = prop.getAttribute 'data-attach'
      if attachment? and not attachment.match /\s+/
        for val in @splitMultiName @component.parent.name or '', attachment
          if name is val
            child = prop
            break
    child

  ###
    Attach a DOMElement to another DOMElement. Attachment can happen by three methods, inserting before, inserting after, inserting at position and replacing.

    @param [DOMElement] parent DOMElement to attach to.
    @param [DOMElement] node DOMElement to attach to parent.
    @param [String, Number] method (Default = append) The method to attach ('prefix'/'before', 'replace', (number) = insert at position) any other method will use the attach method to insert after.
  ###
  attach: (parent, node, method) ->
    switch method
      when 'prefix', 'before'
        parent.insertBefore node, parent.firstChild
        return parent.firstElementChild
      when 'replace'
        for item in parent.children
          try
            parent.removeChild item
          catch e
        parent.appendChild node
        return parent.firstElementChild
      else
        if /^\d+$/.test "#{method}"
          num = Number(method)
          parent.insertBefore node, parent.children[num]
          return parent.children[num]
        else
          parent.appendChild node
          return parent.lastElementChild

  ###
    Create an Element from a template string.
    
    @param [String] template A template String to parse to a DOMElement.
    @return [DOMElement] Parsed DOMElement.
  ###
  create: (template) ->
    temp = document.createElement 'div'
    frag = document.createDocumentFragment()
    temp.innerHTML = template
    temp.firstChild

  ###
    Asynchronously create an Element from a template string.
    
    @param [String] template A template String to parse to a DOMElement.
    @return [DOMElement] Parsed DOMElement.
  ###
  createAsync: (template, callback) -> setTimeout => callback @create template, 0

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
      else throw new Error 'No selector engine defined to tweak.Selector'
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
  on: (element, params...) ->
    elements = @element element or @el
    tweak.Common.on item, params... for item in elements
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
  off: (element, params...) ->
    elements = @element element or @el
    tweak.Common.off item, params... for item in elements
    return

  ###
    Trigger event listener on element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [Event, String] event Event to trigger or string if to create new event.
  ###
  trigger: (element, event) ->
    elements = @element element or @el
    tweak.Common.trigger item, event for item in elements
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
  offsetFrom: (element, from = 'top', relativeTo) ->
    relativeTo ?= document.getElementsByTagName('html')[0]
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
  offsetTop: (element, relativeTo) -> @offsetFrom element, 'top', relativeTo

  ###
    Returns the bottom offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the bottom offset of an element relative to another element (or default to the body).
  ###
  offsetBottom: (element, relativeTo) -> @offsetFrom element, 'bottom', relativeTo
  
  ###
    Returns the left offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = document.getElementsByTagName("html")[0]) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the left offset of an element relative to another element (or default to the body).
  ###
  offsetLeft: (element, relativeTo) -> @offsetFrom element, 'left', relativeTo
  
  ###
    Returns the right offset of an element relative to another element (or default to the body).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String, DOMElement] relativeTo (default = window.document.body) A DOMElement or a string representing a selector query if using a selector engine.
    @return [Number] Returns the right offset of an element relative to another element (or default to the body).
  ###
  offsetRight: (element, relativeTo) -> @offsetFrom element, 'right', relativeTo

  ###
    @private
    Check if a elements attribute contains a string.
    @param [DOMElement, String] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] attribute A DOMElement attribute to check.
    @param [String] classes A string to check existance.
  ###
  hasInAttribute: (element, attribute, item) ->
    if (" #{@element(element)[0][attribute]} ").indexOf(" #{item} ") is -1 then return false
    true

  ###
    Adjust an elements attribute by removing or adding to it.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] attribute A DOMElement attribute to adjust.
    @param [String] method The method of adjustment; add, remove and replace.
    @param [String] classes A string of names to adjust from the attribute of the element(s).
    @param [String] replacement (Optional) A string to pass as the replacement.
  ###
  adjust: (element, attribute, method, classes, replacement) ->
    elements = @element element
    if elements.length is 0 then return
    classes = (classes or '').split /\s+/
    if replacements? then replacements = replacements.split /\s+/
    for item in elements
      if not item? then continue
      name = item[attribute]
      i = 0
      for prop in classes
        if method is 'add'
          if not @hasInAttribute item, attribute, prop then name += " #{prop}"
        else
          if prop is ' ' then continue
          if method is 'remove'
            name = (" #{name} ").split(" #{prop} ").join ' '
          else
            name = if not @hasInAttribute item, attribute, replacement then (" #{name} ").split(" #{prop} ").join " #{replacement} "
            else (" #{name} ").split(" #{prop} ").join ' '
        item[attribute] = name
          .replace /\s{2,}/g,' '
          .replace /(^\s*|\s*$)/g,''
    return

  ###
    Add a string of class names to the given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to add to the element(s).
  ###
  addClass: (element, classes = '') ->
    @adjust element, 'className', 'add', classes
    return

  ###
    Remove a string of class names of the given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove to the element(s).
  ###
  removeClass: (element, classes = '') ->
    @adjust element, 'className', 'remove', classes
    return
 
  ###
    Check of a string of class names is in then given element(s) className attribute.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to remove from the element(s).
  ###
  hasClass: (element, name) ->
    elements = @element element
    if elements.length is 0 then return
    for item in elements
      if not item? then continue
      if not @hasInAttribute element, 'className', name then return false
    true

  ###
    Replace class name values in the given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of classes to replace.
    @param [String] replacement The replacement string.
  ###
  replaceClass: (element, classes, replacement) ->
    @adjust element, 'className', 'replace', classes, replacement
    return

  ###
    Add a string of ids to add to given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] classes A string of ids to add to the given element(s).
  ###
  addID: (element, ids = '') ->
    @adjust element, 'id', 'add', ids
    return

  ###
    Remove a string of ids from the given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] ids A string of ids to remove from the element(s).
  ###
  removeID: (element, ids = '') ->
    @adjust element, 'id', 'remove', ids
    return
 
  ###
    Check of a string of class names is in given element(s) id attribute.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] ids A string of ids to check exists in the given element(s).
  ###
  hasID: (element, name) ->
    elements = @element element
    if elements.length is 0 then return
    for item in elements
      if not item? then continue
      if not @hasInAttribute element, 'id', name then return false
    true

  ###
    Replace id values in the given element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] ids A string of ids to replace.
    @param [String] replacement The replacement string.
  ###
  replaceID: (element, ids, replacement) ->
    @adjust element, 'id', 'replace', ids, replacement
    return
  
tweak.View = tweak.ViewHTML