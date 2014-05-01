###
----- VIEW -----


###
tweak.Viewable = {
  width : window.innerWidth or (document.documentElement or document.documentElement.getElementsByTagName('body')[0]).clientWidth
  height : window.innerHeight or (document.documentElement or document.documentElement.getElementsByTagName('body')[0]).clientHeight
}

class tweak.View

  extend(@, ['require', 'findModule', 'trigger', 'on', 'off', 'splitComponents', 'clone', 'relToAbs'], Common)
  init: -> 

  ### 
    Parameters: data:Object 
    Description: Construct the View with given options  
  ###   
  construct: ->        
  ### 
    Description:      
  ###       
  render: -> 
    @trigger("#{@name}:view:prerender")

    @model.set("rendering", true)

    if not @model.get("id") then @model.set "id", @name.replace(/\//g, "-")
    attachment = @config.attachment or 'after'

    template = if @config.template then @require(@config.template) else @findModule(@component.paths, 'template')
    template = template(@model.data)
    
    @asyncInnerHTML(template, (template) =>

      addClass = (element) =>
        if not element then return
        if not element.className? then element.className = ""
        element.className += " #{@model.get('id')}"

      attach = =>
        @parent = parent = @getParent()
        switch attachment
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
     
      # Check if other components are waiting to finish rendering, if they are then wait
      previousComponent = -1
      comps = @component.parent.components?.data or []
      for item in comps
        if item is @component then break
        previousComponent = item
      if previousComponent isnt -1 and previousComponent.model?.get("rendering")
        @on("#{previousComponent.name}:model:changed:rendering", (render) => 
          if not render then attach()
        )
      else attach()


     

    )

    # Set viewable height and width
    @viewable = tweak.Viewable

    return

  ### 
    Description:      
  ###
  rerender: -> 
    @clear()
    @render()
    @trigger("#{@name}:view:rerendered")

  getChildren: (parent) =>
    nodes = []
    children = (node = {}) =>
      node.children ?= []
      for element in node.children
        ignore = false
        # Check if that a node is part of a lower down component 
        # If it is then we do not want to loop through it later
        # so we can ignore it
        par = @component.parent
        if par.components
          for component in par.components.data
            if component.view.el is element then ignore = true
        if ignore then continue
        if element.children then children(element)
        nodes.push(element)
    # If the parent is the body then put it is the nodes array
    # This allows full web apps that hook into the body
    if parent.body is document.body then nodes.push document.body
    children(parent)
    nodes
  isRendered: -> if @el?.parentNode then true else false

  getComponentNode: (parent, value) ->
    nodes = @getChildren(parent)
    nodes.push parent
    for prop in nodes
      attach = ''
      components = ''
      if child then break
      try
        components = prop.getAttribute('tweak-components') or ''
        attach = prop.getAttribute('tweak-attachments') or ''
      catch e
      attr = "#{components} #{attach}"
      if attr is " " then continue
      for val in @splitComponents(attr)
        if value is val then child = prop
    child

  ### 
    Description:      
  ###
  clear: ->
    if @parent 
      for node in @getChildren(@parent)
        @off(node)

      @parent.innerHTML = ''
      @el = null
  
  ### 
    Description:      
  ###
  getParent: ->
    view = @component.parent?.view
    # The result is the parent el, or it will try to find a node to attach to in the DOM
    parent = view?.el or document.body
    name = @config.attachmentName or @name
    @getComponentNode(parent, name) or view?.el or throw new Error("Unable to find view parent for #{@name} (#{name})")
  
  asyncInnerHTML: (HTML, callback) ->
    setTimeout(=>
      temp = document.createElement("div")
      frag = document.createDocumentFragment()
      temp.innerHTML = HTML
      callback temp.firstChild
    ,
    0)

  # Left in here for now, but redundent
  # Remove when current project is finished
  htmlToDom: (str) -> 
    dom = document.createElement('div')
    dom.innerHTML = str
    dom

  # Tweak has an optional dependecy of any selector engine in the tweak.Selector object
  element: (element, root= @el) -> 
    if typeof element is 'string' 
      if tweak.Selector
        tweak.Selector(element, root)
      else throw new Error("Trying to get element with selector engine, but none defined to tweak.Selector")
    else [element] 

  height: (element) -> @element(element)[0].offsetHeight
  insideHeight: (element) -> @element(element)[0].clientHeight
  width: (element) -> @element(element)[0].offsetWidth
  insideWidth: (element) -> @element(element)[0].clientWidth

  offsetFrom:(element, from = "top", relativeTo = window.document.body) -> 
    element = @element(element)[0]
    elementBounds = element.getBoundingClientRect()
    relativeBounds = relativeTo.getBoundingClientRect()
    elementBounds[from] - relativeBounds[from] 

  offsetTop: (element, relativeTo) -> @offsetFrom(element, "top", relativeTo)
  offestBottom: (element, relativeTo) -> @offsetFrom(element, "bottom", relativeTo)
  offsetLeft: (element, relativeTo) -> @offsetFrom(element, "left", relativeTo)
  offsetRight: (element, relativeTo) -> @offsetFrom(element, "right", relativeTo)

  splitClasses: (classes) ->
    results = []
    if typeof classes isnt "string" then classes = ''
    for key, prop of classes.split(" ")
      if prop isnt "" then results.push prop 
    results

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

  removeClass: (element, classes = '') -> 
    if @element(element).length is 0 then return 
    classes = @splitClasses(classes)
    for item in @element(element)
      if not item? then continue
      for prop in classes
        if prop is ' ' then continue
        item.className = item.className.replace(prop, '')
  
  # Events are stored on the body element. This is to help with event deligation.
  # Events are also stored in the domEvents variable, each view has its own domEvents variable. 
  DOMon: (element, type, callback, bubble = true) -> 
    el = @el
    elements = @element(element)
    for item in elements
      item.addEventListener(type, (e) ->
        callback e, element            
      , false)


  # Go through dom Events and remove events to the body element
  DOMoff: (element, type, callback) -> 
    elements = @element(element)
    for item in elements
      item.removeEventListener(type, callback, false) 

  DOMtrigger: (element, type) ->        
    elements = @element(element)
    e = new Event(type)
    for item in elements
      item.dispatchEvent(e)
