###
  tweak.view.html.js 1.0.0

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###

tweak.Viewable = {
  width : window.innerWidth or (document.documentElement or document.documentElement.getElementsByTagName('body')[0]).clientWidth
  height : window.innerHeight or (document.documentElement or document.documentElement.getElementsByTagName('body')[0]).clientHeight
}

###
  This class extends the View class, extending its rendering functionality for HTML. 
  The ViewHTML class does not provide functionality to manipulate this views 
  presentation layer. To extend the HTMLView to provide extra functionality to 
  manipulate this view's rendered interface (DOM) please include the optional
  tweak.ViewHTMLAdvanced class.  
###
class tweak.ViewHTML extends tweak.View
  # @property [Method] see tweak.Common.require
  require: tweak.Common.require
  # @property [Method] see tweak.Common.splitModuleName
  splitModuleName: tweak.Common.splitModuleName
  # @property [Method] see tweak.Common.findModule
  findModule: tweak.Common.findModule

  ###
    Default initialiser function - called when the view has rendered
  ###
  init: ->

  ###
    Renders the view, using a html template engine. The view is loaded async, this prevents the view from cloging up allowing for complex component structures.
    When the view has been rendered there is a event triggered. This allows an on ready for high components to be achieved, and to make sure that the DOM is available for access.
    The view wont be rendered until its parent view is rendered and any other components views that are waiting to be rendered.
    After the view is rendered the init method will be called.
    There is many options available for rendering through the view class, allowing for powerful rendering functionality.
    However this is quite a perfmormance heavy part of the framework so help tidiing things up would be much appreciated.

    @event rendered The event is called when the view has been rendered.
  ###
  render: (silent) ->
    if @isRendered()
      @triggerEvent "rendered"
      return
      
    if not @model? then throw new Error "There is no model attached to the view - cannot render"
    config = @config
    config.attach ?= {}

    @name = @component.name or @config.name or @uid
    
    # Makes sure that there is an id for this component set, either by the config or by its name
    className = @model.data.className = @config.className or @name.replace /[\/\\]/g, "-"

    # Build the template with the date from the model
    template = if config.template then @require @name, config.template else @findModule @component.paths, './template'
    template = template @model.data
    
    # Create HTML element add add to DOM
    template = @create template 

    # Attach template to the DOM and set @el
    @el = @atttach @parent = parent = @getParent(), template, config.attach.method
      
    # If the add class method from the advanced view is available or equivilant method then add the classes
    if @addClass?
      @addClass @el, className

    # add the unique id as the id for the main element
    if @addID?
      @addID @el, @uid

    if not silent then @triggerEvent "rendered"
    @init()

    # Set viewable height and width
    @viewable = tweak.Viewable
    return

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
        if element.children then children element
        nodes.push element
    # If the parent is the body then put it is the nodes array
    # This allows full web apps that hook into the body
    html = document.getElementsByTagName("html")[0]
    if parent.body is html then nodes.push html
    children parent
    nodes

  ###
    Find a component node by a value (attribute to apply on html is data-attach)
    @param [DOMElment] parent The parent DOMElement to search through to find a given component node
    @param [String] value The component name to look for in the data-attach attribute
    @return [DOMElement] Returns the dom element with matching critera
  ###
  getComponentNode: (parent, value) ->
    nodes = @getChildren parent
    nodes.push parent
    for prop in nodes
      if child then break
      try
        component = prop.getAttribute 'data-attach' or ''
      catch e
      if not component or component is ' ' then continue
      for val in @splitModuleName @name, component
        if value is val then child = prop
    child

  ###
    Clears the view and removed event listeners of DOM elements
  ###
  clear: (element = @el) ->
    if element?.parentNode
      try
        element.parentNode.removeChild element
        element = null
    return

  ###
    Checks to see if the item is rendered; this is detirmined if the node has a parentNode
    @return [Boolean] Returns whether the view has been rendered.
  ###
  isRendered: -> if document.getElementsByTagName("html")[0].contains @el then true else false
  
  ###
    Find the parent DOMElement to this view
    @return [DOMElement] Returns the parent DOMElement
    @throw When looking for a parrent Element and there is not a returnable element you will recieve the following error - "Unable to find view parent for #{@name} (#{name})"
  ###
  getParent: ->
    view = @component.parent?.view
    # The result is the parent el, or it will try to find a node to attach to in the DOM
    html = document.getElementsByTagName("html")[0]
    parent = view?.el or html
    name = @config.attach?.to or @config.attach?.name or @name
    @getComponentNode(parent, name) or @getComponentNode(html, name) or parent or throw new Error "Unable to find view parent for #{@name} (#{name})"

  attach: (parent, node, method) ->
    switch method
      when 'top', 'before'
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
        parent.appendChild node
        return parent.lastElementChild

  create: (template) ->
    temp = document.createElement "div"
    frag = document.createDocumentFragment()
    temp.innerHTML = template
    temp.firstChild


tweak.View = tweak.ViewHTML