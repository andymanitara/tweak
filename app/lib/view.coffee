tweak.Viewable = {
  width : window.innerWidth or (document.documentElement or document.documentElement.getElementsByTagName('body')[0]).clientWidth
  height : window.innerHeight or (document.documentElement or document.documentElement.getElementsByTagName('body')[0]).clientHeight
}

###
  The view is the DOM controller. This should be used for code that doesnt really control any logic but how the view is displayed. For example animations.
  The view uses a templating engine to provide the html to the DOM.
  The view in common MV* frameworks is typically used to directly listen for model changes to rerender however typically this should be done in the controller.
  The data in the model is passed into the views template, allowing for easy manipulation of the view.

  @todo Reduce the complexity of the rendering functionality
  @include tweak.Common.Empty
  @include tweak.Common.Events
  @include tweak.Common.Collections
  @include tweak.Common.Arrays
  @include tweak.Common.Modules
  @include tweak.Common.Components
###
class tweak.View
  
  # @property [Integer] The uid of this object - for unique reference
  uid: 0
  # @property [Integer] The component uid of this object - for unique reference of component
  cuid: 0
  # @property [Component] The root component
  root: null

  tweak.Extend @, [
    tweak.Common.Empty,
    tweak.Common.Events,
    tweak.Common.Modules,
    tweak.Common.Collections,
    tweak.Common.Arrays,
    tweak.Common.Modules,
    tweak.Common.Components
  ]

  # @private
  constructor: ->
    # Set uid
    @uid = "v_#{tweak.uids.v++}"

  ###
    Renders the view, using a html template engine. The view is loaded async, this prevents the view from cloging up allowing for complex component structures.
    When the view has been rendered there is a event triggered. This allows an on ready for high components to be achieved, and to make sure that the DOM is available for access.
    The view wont be rendered until its parent view is rendered and any other components views that are waiting to be rendered.
    After the view is rendered the init method will be called.
    There is many options available for rendering through the view class, allowing for powerful rendering functionality.
    However this is quite a perfmormance heavy part of the framework so help tidiing things up would be much appreciated.

    @todo Reduce the complexity of the rendering functionality
    @event "#{@name}:view:rendered" The event is called when the view has been rendered.
    @event "#{@component.uid}:view:rendered" The event is called when the view has been rendered.
    @event "#{@uid}:rendered" The event is called when the view has been rendered.
  ###
  render: ->
    @model.set "rendering", true
    
    # Makes sure that there is an id for this component set, either by the config or by its name
    @model.set "id", @name.replace(/\//g, "-")
    # Build the template with the date from the model
    template = if @config.template then @require(@config.template) else @findModule(@component.paths, 'template')
    template = template(@model.data)
    
    @asyncHTML(template, (template) =>
      # Attach nodes to the dome
      # It can either replace whats is in its parent node, or append after or be inserted before.
      attach = =>
        @parent = parent = @getParent()
        switch @config.attachment or 'after'
          when 'bottom', 'after'
            @parent.appendChild(template)
            @el = @parent.lastElementChild
          when 'top', 'before'
            @parent.insertBefore(template, @parent.firstChild)
            @el = @parent.firstElementChild
          when 'replace'
            for item in @parent.children
              try
                @parent.removeChild item
              catch e
            @parent.appendChild template
            @el = @parent.firstElementChild

        @addClass(@el, @model.get("id"))
        @addClass(@el, @config.class or "")
        @model.set "rendering", false
        @__trigger "view:rendered"
        @init()
     
      # Check if other components are waiting to finish rendering, if they are then wait to attach to DOM
      previousComponent = -1
      comps = @component.parent.components?.data or []
      for item in comps
        if item is @component then break
        previousComponent = item
      if previousComponent isnt -1 and previousComponent.model?.get "rendering"
        @on("#{previousComponent.uid}:model:changed:rendering", (render) ->
          if not render then attach()
        )
      else attach()
    )

    # Set viewable height and width
    @viewable = tweak.Viewable

    return

  ###
    The view will be cleared then rendered again.
    @event "#{@name}:view:rerendered" The event is called when the view has been rerendered.
    @event "#{@component.uid}:view:rerendered" The event is called when the view has been rerendered.
    @event "#{@uid}:rerendered" The event is called when the view has been rerendered.
  ###
  rerender: ->
    @clear()
    @render()
    @on("#{@uid}:rendered", ->
      @__trigger "view:rerendered"
    )

  ###
    Get the chidlren nodes of an element
    @param [DOMElement] parent The element to get the children nodes of
    @return [Array<DOMElement>] Returns an array of children nodes from a parent Element
  ###
  getChildren: (parent) =>
    nodes = []
    children = (node = {}) =>
      node.children ?= []
      for element in node.children
        # Check if that a node is part of a lower down component
        # If it is then we do not want to loop through it later
        # so we can ignore it
        par = @component.parent
        if par.components
          for component in par.components.data
            if component.view.el is element then continue
        if element.children then children(element)
        nodes.push(element)
    # If the parent is the body then put it is the nodes array
    # This allows full web apps that hook into the body
    if parent.body is document.body then nodes.push document.body
    children(parent)
    nodes

  ###
    Find a component node by a value (attribute to apply on html is tweak-component)
    @param [DOMElment] parent The parent DOMElement to search through to find a given component node
    @param [String] value The component name to look for in the tweak-component attribute
    @return [DOMElement] Returns the dom element with matching critera
  ###
  getComponentNode: (parent, value) ->
    nodes = @getChildren(parent)
    nodes.push parent
    for prop in nodes
      components = ''
      if child then break
      try
        components = prop.getAttribute('tweak-components') or ''
      catch e
      if components is " " then continue
      for val in @splitComponents(components)
        if value is val then child = prop
    child

  ###
    Clears the view and removed event listeners of DOM elements
  ###
  clear: ->
    if @el?.parentNode
      try
        @el.parentNode.removeChild @el
        @el = null

  ###
    Checks to see if the item is rendered; this is detirmined if the node has a parentNode
    @return [Boolean] Returns whether the view has been rendered.
  ###
  isRendered: -> if document.body.contains @el then true else false
  
  ###
    Find the parent DOMElement to this view
    @return [DOMElement] Returns the parent DOMElement
    @throw When looking for a parrent Element and there is not a returnable element you will recieve the following error - "Unable to find view parent for #{@name} (#{name})"
  ###
  getParent: ->
    view = @component.parent?.view
    # The result is the parent el, or it will try to find a node to attach to in the DOM
    parent = view?.el or document.body
    name = @config.attachmentName or @name
    @getComponentNode(parent, name) or view?.el or throw new Error("Unable to find view parent for #{@name} (#{name})")
  
  ###
    Async html to a function, this allows dynamic building of components without holding up parts of the system
    @param [String] HTML A String containing html to build into a dom object
    @param [Function] callback A method to pass the built up dom object to
  ###
  asyncHTML: (HTML, callback) ->
    setTimeout(->
      temp = document.createElement("div")
      frag = document.createDocumentFragment()
      temp.innerHTML = HTML
      callback temp.firstChild
    ,
    0)

  ###
    Tweak has an optional dependecy of any selector engine in the tweak.Selector object
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [DOMElement] root (Default = @el) The element root to search for elements with a selector engine
    @return [Array<DOMElement>] Returns an array of DOMElements
    @throw When trying to use a selector engine without having one assigned to the tweak.Selector property you will recieve the following error - "Trying to get element with selector engine, but none defined to tweak.Selector"
  ###
  element: (element, root= @el) ->
    if typeof element is 'string'
      if tweak.Selector
        tweak.Selector(element, root)
      else throw new Error("Trying to get element with selector engine, but none defined to tweak.Selector")
    else [element]

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
    @param [String, DOMElement] relativeTo (default = window.document.body) A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the element offset value relative to another element
  ###
  offsetFrom:(element, from = "top", relativeTo = window.document.body) ->
    relativeTo = @element(relativeTo)[0]
    element = @element(element)[0]
    elementBounds = element.getBoundingClientRect()
    relativeBounds = relativeTo.getBoundingClientRect()
    elementBounds[from] - relativeBounds[from]
  
  ###
    Returns the top offset of an element relative to another element (or default to the body)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String, DOMElement] relativeTo (default = window.document.body) A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the top offset of an element relative to another element (or default to the body)
  ###
  offsetTop: (element, relativeTo) -> @offsetFrom(element, "top", relativeTo)

  ###
    Returns the bottom offset of an element relative to another element (or default to the body)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String, DOMElement] relativeTo (default = window.document.body) A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the bottom offset of an element relative to another element (or default to the body)
  ###
  offsetBottom: (element, relativeTo) -> @offsetFrom(element, "bottom", relativeTo)
  
  ###
    Returns the left offset of an element relative to another element (or default to the body)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String, DOMElement] relativeTo (default = window.document.body) A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the left offset of an element relative to another element (or default to the body)
  ###
  offsetLeft: (element, relativeTo) -> @offsetFrom(element, "left", relativeTo)
  
  ###
    Returns the right offset of an element relative to another element (or default to the body)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String, DOMElement] relativeTo (default = window.document.body) A DOMElement or a string represeting a selector query if using a selector engine
    @return [Number] Returns the right offset of an element relative to another element (or default to the body)
  ###
  offsetRight: (element, relativeTo) -> @offsetFrom(element, "right", relativeTo)

  ###
    @private
    Split classes from a string to an array
  ###
  splitClasses: (classes) ->
    results = []
    if typeof classes isnt "string" then classes = ''
    for key, prop of classes.split(" ")
      if prop isnt "" then results.push prop
    results

  ###
    Add a string of class names to an element(s)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to add to the element(s)
  ###
  addClass: (element, classes = '') ->
    elements = @element element
    if elements.length is 0 then return
    classes = @splitClasses classes
    for item in elements
      if not item? then continue
      for prop in classes
        className = item.className
        if not @hasClass item, prop then className += " #{prop}"
        item.className = className
          .replace /\s{2,}/g,' '
          .replace /(^\s*|\s*$)/g,''

  ###
    Remove a string of class names of an element(s)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to remove to the element(s)
  ###
  removeClass: (element, classes = '') ->
    elements = @element element
    if elements.length is 0 then return
    classes = @splitClasses classes
    for item in elements
      if not item? then continue
      for prop in classes
        if prop is ' ' then continue
        className = (" #{item.className} ").split(" #{prop} ").join ' '
        item.className = className
          .replace /\s{2,}/g,' '
          .replace /(^\s*|\s*$)/g,''
 
  ###
    Check of a string of class names is in an element(s) class
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to remove to the element(s)
  ###
  hasClass: (element, name) ->
    elements = @element(element)
    if elements.length is 0 then return
    for item in elements
      if not item? then continue
      if (" #{item.className} ").indexOf(" #{name} ") is -1 then return false
    true


  ###
    Replace of a string of class names in element(s)
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] classes A string of classes to remove to the element(s)
  ###
  replaceClass: (element, orig, classes) ->
    elements = @element(element)
    if elements.length is 0 then return
    classes = @splitClasses(classes)
    orig = @splitClasses(orig)
    for item in elements
      if not item? then continue
      i = 0
      for prop in orig
        if prop is ' ' then continue
        className = (" #{item.className} ").split(" #{prop} ").join " #{classes[i++]} "
        item.className = className
          .replace /\s{2,}/g,' '
          .replace /(^\s*|\s*$)/g,''

    
  
  ###
    Apply event listener to element(s)
    @note Use the on method, which shortcuts to this if parameters match, or if performance is critical then you can skip a check and directly use this method.
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] type The type of event
    @param [Function] callback The method to apply to the event listener
  ###
  DOMon: (element, type, callback) ->
    el = @el
    elements = @element(element)
    for item in elements
      item.addEventListener(type, (e) ->
        callback e, element
      , false)

  ###
    Remove event listener to element(s)
    @note Use the off method, which shortcuts to this if parameters match, or if performance is critical then you can skip a check and directly use this method.
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] type The type of event
    @param [Function] callback The method that was applied to the event listener
  ###
  DOMoff: (element, type, callback) ->
    elements = @element(element)
    for item in elements
      item.removeEventListener(type, callback, false)

  ###
    Trigger event listener on element(s)
    @note Use the trigger method, which shortcuts to this if parameters match, or if performance is critical then you can skip a check and directly use this method.
    @param [String, DOMElement] element A DOMElement or a string represeting a selector query if using a selector engine
    @param [String] type The type of event
  ###
  DOMtrigger: (element, type) ->
    elements = @element(element)
    e = new Event(type)
    for item in elements
      item.dispatchEvent(e)