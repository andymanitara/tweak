###
  A View is a module used as a presentation layer. Which is used to render,
  manipulate and listen to an interface. The Model, View and Controller separates
  logic of the Views interaction to that of data and functionality. This helps to
  keep code organized and tangle free - the View should primarily be used to render,
  manipulate and listen to the presentation layer. A View consists of a template to
  which data is bound to and rendered/re-rendered.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
###
class tweak.View extends tweak.Events
 
  # @property [Integer] The uid of this object - for unique reference.
  uid: 0
  # @property [Method] see tweak.super
  super: tweak.super

  $ = tweak.$

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
    template = @template @model.data
    
    # Create HTML element add add to DOM
    rendered = (template) =>
      # Attach template to the DOM and set @el
      attachTo = @config.attach?.to or @config.attach?.name or @name
      parent = @component.parent?.view?.el
      html = document.documentElement
      attachment = @getAttachmentNode(parent) or @getAttachmentNode(html) or parent or html
      
      @$el = $(@attach attachment, template, config.attach.method)
      @el = @$el[0]
        
      # Attempt to add class and uid
      @$el.addClass classNames.join ' '
      @$el.attr 'id', @uid

      if not silent then @triggerEvent 'rendered'
      @init()

    @createAsync template, rendered
    return

  ###
    Clears the View and removed event listeners of DOM elements.
  ###
  remove: (element = @el) -> $(element).remove()

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
    nodes = @element(parent, '[data-attach]')
    for prop in nodes or []
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
  element: (element, root= @el) -> $(element, root)