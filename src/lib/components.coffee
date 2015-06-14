###
  This class provides a collection of components. Upon initialisation components
  are dynamically built, from its configuration. The configuration for this
  component is an Array of component names (Strings). The component names are
  then used to create a component. Components nested within those components are
  then initialised creating a powerful scope of nest components that are completely
  unique to themselves.

  Examples are not exact, and will not directly represent valid code; the aim of
  an example is to be a rough guide. JS is chosen as the default language to
  represent Tweak.js as those using 'compile-to-languages' should have a good
  understanding of JS and be able to translate the examples to a chosen language.
  Support can be found through the community if needed. Please see our
  Gitter community for more help {http://gitter.im/blake-newman/TweakJS}.
###
class Tweak.Components extends Tweak.Collection
  ###
   Construct the Collection with given options from the Components configuration.
  ###
  init: ->
    @_data = []
    data = []
    _absolute = (path) => Tweak.toAbsolute @component.name, path
    _paths = (paths) => _absolute path for path in Tweak.splitPaths paths
    _add = (component) =>
      @_data.push component
      @length++
      component.init()

    for item in @component.config.components
      obj = {}
      if item instanceof Array
        _extends = _absolute item[1]
        for name in _paths item[0] then _add new Tweak.Component @, {path, extends:_extends}
      else if typeof item is 'string'
        for name in _paths item then _add new Tweak.Component @, {name}
      else
        item.extends = _absolute item.extends
        for name in _paths item.name
          item.name = name
          _add new Tweak.Component @, item
    return

  ###
    @private
    Reusable method to render and re-render.
    @param [String] type The type of rendering to do either 'render' or 'rerender'.
  ###
  __componentRender: (type) ->
    if @length is 0
      @triggerEvent 'ready'
    else
      @total = 0
      for item in @_data
        item.controller.addEvent 'ready', ->
          if ++@total is @length then @triggerEvent 'ready'
        , @, 1
        item[type]()
    return

  ###
    Renders all of its Components.
    @event ready Triggers ready event when itself and its sub-Components are ready/rendered.
  ###
  render: ->
    @__componentRender 'render'
    return

  ###
    Re-render all of its Components.
    @event ready Triggers ready event when itself and its sub-Components are ready/re-rendered.
  ###
  rerender: ->
    @__componentRender 'rerender'
    return

  ###
    Find Component with matching data in model.
    @param [String] property The property to find matching value against.
    @param [*] value Data to compare to.
    @return [Array] An array of matching Components.
  ###
  whereData: (property, value) ->
    result = []
    componentData = @_data
    for collectionKey, data of componentData
      modelData = data.model.data or model.data
      for key, prop of modelData when key is property and prop is value
        result.push data
    result

  ###
    Reset this Collection of components. Also destroys it's components (views removed from DOM).
    @event changed Triggers a generic event that the store has been updated.
  ###
  reset: ->
    for item in @_data
      item.destroy()
    super()
    return