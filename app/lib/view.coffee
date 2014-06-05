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
  @include tweak.Common.clone
  @include tweak.Common.construct
  @include tweak.Common.findModule
  @include tweak.Common.init
  @include tweak.Common.off
  @include tweak.Common.on
  @include tweak.Common.relToAbs
  @include tweak.Common.require
  @include tweak.Common.splitComponents
  @include tweak.Common.trigger
###
class tweak.View

  tweak.Extend(@, ['clone', 'construct', 'findModule', 'init', 'off', 'on', 'relToAbs', 'require', 'splitComponents', 'trigger'], tweak.Common)

  ###
    Renders the view, using a html template engine. The view is loaded async, this prevents the view from cloging up allowing for complex component structures.
    When the view has been rendered there is a event triggered. This allows an on ready for high components to be achieved, and to make sure that the DOM is available for access.
    The view wont be rendered until its parent view is rendered and any other components views that are waiting to be rendered.
    After the view is rendered the init method will be called.
    There is many options available for rendering through the view class, allowing for powerful rendering functionality.
    However this is quite a perfmormance heavy part of the framework so help tidiing things up would be much appreciated.

    @todo Reduce the complexity of the rendering functionality
    @event "#{@name}:view:rendered" The event is called when the view has been rendered.
  ###
  render: ->
    # Triggers event so you an do some configurations before it renders
    @trigger("#{@name}:view:prerender")

    @model.set("rendering", true)
    
    # Makes sure that there is an id for this component set, either by the config or by its name
    @model.set "id",  @config.className or @name.replace(/\//g, "-")
    # Build the template with the date from the model
    template = if @config.template then @require(@config.template) else @findModule(@component.paths, 'template')
    template = template(@model.data)
    
    @asyncInnerHTML(template, (template) =>

      # adds a unique class to the element based on the component name
      addClass = (element) =>
        if not element then return
        if not element.className? then element.className = ""
        element.className += " #{@model.get('id')}"


      # Attach nodes to the dome
      # It can either replace whats is in its parent node, or append after or be inserted before.
      attach = =>
        @parent = parent = @getParent()
        switch @config.attachment or 'after'
          when 'bottom', 'after'
            @parent.appendChild(template)
            addClass(@parent.lastElementChild)
            @el = @parent.lastElementChild
          when 'top', 'before'
            @parent.insertBefore(template, @parent.firstChild)
            addClass(@parent.firstElementChild)
            @el = @parent.firstElementChild
          when 'replace'
            for item in @parent.children
              try
                @parent.removeChild item
              catch e
            @parent.appendChild template
            addClass(@parent.firstElementChild)
            @el = @parent.firstElementChild

        @model.set("rendering", false)
        @trigger("#{@name}:view:rendered")
        @init()
     
      # Check if other components are waiting to finish rendering, if they are then wait to attach to DOM
      previousComponent = -1
      comps = @component.parent.components?.data or []
      for item in comps
        if item is @component then break
        previousComponent = item
      if previousComponent isnt -1 and previousComponent.model?.get("rendering")
        @on("#{previousComponent.name}:model:changed:rendering", (render) ->
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
  ###
  rerender: ->
    @clear()
    @render()
    @on("#{@name}:view:rendered", =>
      @trigger("#{@name}:view:rerendered")
    )

  ###
    @param []
    @return []
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
    @param []
    @param []
    @return []
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
    @note Is removing the event listeners needed, or will it clear from the memory automatically when it is cleared?
  ###
  clear: ->
    if @parent
      for node in @getChildren(@parent)
        @off(node)

      @parent.innerHTML = ''
      @el = null

  ###
    Checks to see if the item is rendered; this is detirmined if the node has a parentNode
    @return [Boolean] Returns whether the view has been rendered.
  ###
  isRendered: -> if @el?.parentNode then true else false
  
  ###
    @return []
  ###
  getParent: ->
    view = @component.parent?.view
    # The result is the parent el, or it will try to find a node to attach to in the DOM
    parent = view?.el or document.body
    name = @config.attachmentName or @name
    @getComponentNode(parent, name) or view?.el or throw new Error("Unable to find view parent for #{@name} (#{name})")
  
  ###
    @param []
    @param []
    @return []
    @note Would it be prefered to be asyncHTML?
  ###
  asyncInnerHTML: (HTML, callback) ->
    setTimeout(->
      temp = document.createElement("div")
      frag = document.createDocumentFragment()
      temp.innerHTML = HTML
      callback temp.firstChild
    ,
    0)
  ###
    Tweak has an optional dependecy of any selector engine in the tweak.Selector object
    @param []
    @param []
    @return []
  ###
  element: (element, root= @el) ->
    if typeof element is 'string'
      if tweak.Selector
        tweak.Selector(element, root)
      else throw new Error("Trying to get element with selector engine, but none defined to tweak.Selector")
    else [element]

  ###
    @param []
    @return []
  ###
  height: (element) -> @element(element)[0].offsetHeight

  ###
    @param []
    @return []
  ###
  insideHeight: (element) -> @element(element)[0].clientHeight

  ###
    @param []
    @return []
  ###
  width: (element) -> @element(element)[0].offsetWidth

  ###
    @param []
    @return []
  ###
  insideWidth: (element) -> @element(element)[0].clientWidth

  ###
    @param []
    @param []
    @param []
    @return []
  ###
  offsetFrom:(element, from = "top", relativeTo = window.document.body) ->
    element = @element(element)[0]
    elementBounds = element.getBoundingClientRect()
    relativeBounds = relativeTo.getBoundingClientRect()
    elementBounds[from] - relativeBounds[from]
  
  ###
    @param []
    @param []
    @return []
  ###
  offsetTop: (element, relativeTo) -> @offsetFrom(element, "top", relativeTo)

  ###
    @param []
    @param []
    @return []
  ###
  offestBottom: (element, relativeTo) -> @offsetFrom(element, "bottom", relativeTo)
  
  ###
    @param []
    @param []
    @return []
  ###
  offsetLeft: (element, relativeTo) -> @offsetFrom(element, "left", relativeTo)
  
  ###
    @param []
    @param []
    @return []
  ###
  offsetRight: (element, relativeTo) -> @offsetFrom(element, "right", relativeTo)

  ###
    @param []
    @return []
  ###
  splitClasses: (classes) ->
    results = []
    if typeof classes isnt "string" then classes = ''
    for key, prop of classes.split(" ")
      if prop isnt "" then results.push prop
    results

  ###
    @param []
    @param []
    @note This could be achieved with cleaner code with REGEX?
  ###
  addClass: (element, classes = '') ->
    addingClasses = @splitClasses(classes)
    for item in @element(element)
      if not item? then continue
      currentClasses = @splitClasses(item.className)
      for addClass in addingClasses
        add = true
        for curClass in currentClasses
          if curClass is addClass then add = false
        if add then item.className += " #{addClass}"
      item.className = item.className.replace(/\s*/g,' ')

  ###
    @param []
    @param []
    @note This could be achieved with cleaner code with REGEX?
  ###
  removeClass: (element, classes = '') ->
    if @element(element).length is 0 then return
    classes = @splitClasses(classes)
    for item in @element(element)
      if not item? then continue
      for prop in classes
        if prop is ' ' then continue
        item.className = item.className.replace(prop, '')
  
  ###
    @param []
    @param []
    @param []
  ###
  DOMon: (element, type, callback) ->
    el = @el
    elements = @element(element)
    for item in elements
      item.addEventListener(type, (e) ->
        callback e, element
      , false)

  ###
    @param []
    @param []
    @param []
  ###
  DOMoff: (element, type, callback) ->
    elements = @element(element)
    for item in elements
      item.removeEventListener(type, callback, false)

  ###
    @param []
    @param []
  ###
  DOMtrigger: (element, type) ->
    elements = @element(element)
    e = new Event(type)
    for item in elements
      item.dispatchEvent(e)