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
class Tweak.View extends Tweak.Events
 
  $ = Tweak.$

  ###
    Default initialiser function - called when the View has rendered
  ###
  init: ->

  ###
    Default template method. This is used to generate a html fro a template engine ect, to be used during the rendering
    process. By default this method will generate a template through handlebars, it will also seek out the template
    through the module loader. This may be cross compatible with other template engines, however you can overwrite this
    method if you want to use an alternative non-compatible template engine. There may also be an extension available
    for your chosen template engine. Search [name]Tweaked for possible premade extensions.
    @param [Object] data An object of data that can be passed to the template.
    @return [String] Returns a string representaion of HTML to attach to view during render.
  ###
  template: (data) ->
    (if config.template then Tweak.Common.require config.template else Tweak.Common.findModule @component.paths, './template') data

  ###
    Default attach method. This is used to attach a HTML string to an element. You can override this method with your
    own attachment functionality.

    @param [DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [String] content A HTML representation of a string
    @return [DOMElement] Returns athe attached DOMElement
  ###
  attach: (parent, content) ->
    content = $(content)[0]
    switch method = @component.config.view?.attach?.method
      when 'prefix', 'before'
        parent.insertBefore content, parent.firstChild
        return parent.firstElementChild
      when 'replace'
        for item in parent.children
          try
            parent.removeChild item
          catch e
        parent.appendChild content
        return parent.firstElementChild
      else
        if /^\d+$/.test "#{method}"
          num = Number(method)
          parent.insertBefore content, parent.children[num]
          return parent.children[num]
        else
          parent.appendChild content
          return parent.lastElementChild

  ###
    Checks to see if the item is attached to ; this is determined if the node has a parentNode.
    @return [Boolean] Returns whether the View has been rendered.
  ###
  isAttached: (element = @el, parent = document.documentElement) -> parent.contains element

  ###
    Renders the View, using a html template engine. The View is loaded asynchronously, this prevents the DOM from
    from congesting during rendering. The View won't be rendered until its parent View is rendered and any other
    components Views that are waiting to be rendered; this makes sure that components are rendered into in there
    correct positions.
    
    @param [Boolean] silent (Optional, default = false) If true events are not triggered upon any changes.
    @event rendered The event is called when the View has been rendered.
  ###
  render: (silent) ->
    if @isAttached() and not silent then return @triggerEvent 'rendered'

    config = @component.config.view

    _getAttachment = (parent) =>
      child = null
      if not parent then return
      # The result is the parent el, or it will try to find a node to attach to in the DOM
      check = (elements) =>
        for prop in elements
          if child then break
          attachment = prop.getAttribute 'data-attach'
          if attachment? and not attachment.match /\s+/
            for val in Tweak.Common.splitPath attachment
              val = Tweak.Common.toAbsolute @component.parent.name or ''
              if name is val
                child = prop
                break
      name = config.attach?.to or @component.name
      check parent
      check $('[data-attach]', parent)
      child
    
    # Attach template to the DOM and set @el
    attachTo = config?.attach?.to or @component.name
    parent = @component.parent?.view?.el
    attachment = _getAttachment(parent) or _getAttachment(document.documentElement) or parent or document.documentElement
    
    @$el = $(@attach attachment, @template @component.config.view.data or @model._data)
    @el = @$el[0]
      
    # Add class names
    names = Tweak.Common.clone @component.paths
    if names.indexOf(@component.name) is -1 then names.unshift @component.name
    classNames = for name in names then name.replace /[\/\\]/g, '-'
    @$el.addClass classNames.join ' '

    if not silent then @triggerEvent 'rendered'
    @init()
    return

  ###
    Clears and element and removes event listeners on itself and child DOM elements.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
  ###
  clear: (element = @el) ->
    $(element).remove()
    return

  ###
    Select a DOMElement from within the assigned view element
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [DOMElement] root (Default = @el) The element root to search for elements with a selector engine.
    @return [Array<DOMElement>] An array of DOMElements.
  ###
  element: (element, root= @el) ->
    if element instanceof Array
      $ item, root for item in element
    else $ element, root