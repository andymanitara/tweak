###
  The core View.
  
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

  ###
    The constructor initialises the controllers unique ID and its root context and sets the Views configuration.
  ###
  constructor: (@config = {}) -> @uid = "v_#{tweak.uids.v++}"

  ###
    Default initialiser function - called when the View has rendered.
  ###
  init: ->

  ###
    Renders the View.
    @event rendered View has been rendered.
  ###
  render: (silent) ->
    if not silent then @triggerEvent "rendered"
    return

  ###
    Re-renders the View.
    @event rendered View has been rendered.
    @event rerendered View has been re-rendered.
  ###
  rerender: (silent) ->
    @clear()
    @render silent
    if not silent
      @addEvent "rendered", ->
        @triggerEvent "rerendered"
      , 1
    return

  ###
    Checks to see if the item is rendered; this is determined if the node has a parentNode.
    @return [Boolean] Returns whether the View has been rendered.
  ###
  isRendered: ->
    return true

  ###
    Clears the View
  ###
  clear: ->
    return