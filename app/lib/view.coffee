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
    The constructor initialises the Views unique ID and config.
  ###
  constructor: (@config ={}) -> @uid = "v_#{tweak.uids.v++}"
    

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
    if @isAttached() and not silent then return @triggerEvent 'rendered'

    _getAttachment = (parent) =>
      child = null
      if not parent then return
      # The result is the parent el, or it will try to find a node to attach to in the DOM
      check = (elements) =>
        for prop in elements
          if child then break
          attachment = prop.getAttribute 'data-attach'
          if attachment? and not attachment.match /\s+/
            for val in tweak.Common.splitMultiName @component.parent.name or '', attachment
              if name is val
                child = prop
                break
      name = @config.attach?.to or @component.name
      check parent
      check $('[data-attach]', parent)
      child

    _attach = (parent, content, method) ->
      content = $(content)[0]
      switch method
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
      
    @config.attach ?= {}
    
    # Makes sure that there is an id for this component set, either by the config or by its name
    classNames = for name in @component.names then name.replace /[\/\\]/g, '-'

    # Build the template with the date from the model
    template = (if @config.template then tweak.Common.require @config.template else tweak.Common.findModule @component.paths, './template') @config.view?.data or @model.data
       
    # Attach template to the DOM and set @el
    attachTo = @config.attach?.to or @component.name
    console.log attachTo
    parent = @component.parent?.view?.el
    attachment = _getAttachment(parent) or _getAttachment(document.documentElement) or parent or document.documentElement
    
    @$el = $(_attach attachment, template, @config.attach.method)
    @el = @$el[0]
      
    # Attempt to add class and uid
    @$el.addClass classNames.join ' '
    @$el.attr 'id', @uid

    if not silent then @triggerEvent 'rendered'
    @init()
    return

  ###
    Clears and element and removes event listeners on itself and child DOM elements.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
  ###
  clear: (element = @el) ->
    element = $(element)[0]
    remove = element.remove
    if remove?
      remove()
    else
      elements = $ '*', element
      elements.push element
      for el in elements
        @off el
      element.parentNode.removeChild element
      element = null
    return
  ###
    Checks to see if the item is attached to ; this is determined if the node has a parentNode.
    @return [Boolean] Returns whether the View has been rendered.
  ###
  isAttached: (element = @el, parent = document.documentElement) -> parent.contains element

  ###
    Select a DOMElement using a selector engine dependency affixed to the tweak.Selector object.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [DOMElement] root (Default = @el) The element root to search for elements with a selector engine.
    @return [Array<DOMElement>] An array of DOMElements.
  ###
  element: (element, root= @el) ->
    if element instanceof Array
      $ item, root for item in element
    else $ element, root

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
    if not $(element).on?(params...)
      elements = @element(element or @el)
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
    if not $(element).off?(params...)
      elements = @element(element or @el)
      tweak.Common.off item, params... for item in elements
    return

  ###
    Trigger event listener on element(s).
    @param [String, DOMElement] element A DOMElement or a string representing a selector query if using a selector engine.
    @param [Event, String] event Event to trigger or string if to create new event.
  ###
  trigger: (element, params...) ->
    if not $(element).trigger?(params...)
      elements = @element(element or @el)
      tweak.Common.trigger item, params... for item in elements
    return