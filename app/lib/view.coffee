###
  The core view.
  
  A View is a module used as a presentation layer. Which is used to render, manipulate and listen to an interface.
  The Model, View and Controller separates logic of the Views interaction to that of data and functionality. 
  This helps to keep code organized and tangle free - the View should primarily be used to render, manipulate and
  listen to the presentation layer. A View consists of a template to which data is binded to and rendered/re-rendered.
###
class tweak.View extends tweak.EventSystem
 
  # @property [Integer] The uid of this object - for unique reference
  uid: 0
  # @property [Method] see tweak.super
  super: tweak.super

  ###
    The constructor initialises the controllers unique ID and its root context and sets the views configuration.
  ###
  constructor: (@config = {}) -> @uid = "v_#{tweak.uids.v++}"

  ###
    Default initialiser function - called when the view has rendered
  ###
  init: ->

  ###
    Renders the view.
    @event rendered View has been rendered.
  ###
  render: (silent) ->
    if not silent then @triggerEvent "rendered"
    return

  ###
    Rerenders the view
    @event rendered View has been rendered.
    @event rerendered View has been rerendered.
  ###
  rerender: (silent) ->
    @clear()
    @render silent
    if not silent
      @onEvent "rendered", ->
        @triggerEvent "rerendered"
      ,1
    return

  ###
    Checks to see if the item is rendered; this is detirmined if the node has a parentNode
    @return [Boolean] Returns whether the view has been rendered.
  ###
  isRendered: ->
    return true

  ###
    Clears the view
  ###
  clear: ->
    return