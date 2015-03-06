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
  # @property [Method] see tweak.Common.splitMultiName
  splitMultiName: tweak.Common.splitMultiName
  # @property [Method] see tweak.Common.relToAbs
  relToAbs: tweak.Common.relToAbs
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
    rendered = (template) =>
      # Attach template to the DOM and set @el
      @el = @attach @getAttachmentNode(), template, config.attach.method
        
      # Attempt to add class and uid
      strip = /^\s+|\s\s+|\s+$/
      @el.className = "#{@el.className} #{className}".replace strip, ''
      @el.id = "#{@el.id} #{@uid}".replace strip, ''

      if not silent then @triggerEvent "rendered"
      @init()

    @createAsync template, rendered
    return

  ###
    Get the children nodes of an element
    @param [DOMElement] parent The element to retrieve the children of
    @param [Boolean] recursive (Default: true) Whether to recursively go through its childerns children to get a full list
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
    Get the attachment node for this element
    @return [DOMElement] Returns the parent DOMElement
    @throw When looking for a parrent Element and there is not a returnable element you will recieve the following error - "Unable to find view parent for #{@name} (#{name})"
  ###
  getAttachmentNode: ->
    # The result is the parent el, or it will try to find a node to attach to in the DOM
    parent = @component.parent?.view?.el or document.getElementsByTagName("html")[0]
    name = @config.attach?.to or @config.attach?.name or @name
    nodes = @getChildren parent
    nodes.push parent
    for prop in nodes
      if child then break
      attachment = prop.getAttribute 'data-attach'
      if attachment? and not attachment.match /\s+/
        for val in @splitMultiName name, attachment
          if name is val
            child = prop
            break
    child or parent or throw new Error "Unable to find view parent for #{@name} (#{name})"

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

  createAsync: (template, callback) -> setTimeout => callback @create template, 0
  
tweak.View = tweak.ViewHTML