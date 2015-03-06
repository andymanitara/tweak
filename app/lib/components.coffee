###
  The Components collection is used to allow a Component to have multiple sub Components; allowing a extensive powerful hierarchy system of Components; which also allows for multiple areas of views.
  For example a view may have to sections of user interaction that does two different things and gets two different sets of data, but its parent view is about a particular item.
  This example shows the power of relations in the framework. As the two views are different with different data being fed in these can be two sub Components, allowing separation of code.
  This allow reloading of views without affect other views, a bit like regions in backbone marionette. However your code can now be much more structured in this format and easier to understand where things are happening.
###
class tweak.Components extends tweak.Collection    
  # @property [String] The type of storage
  _type: "components"
  # @property [Method] see tweak.Common.relToAbs
  relToAbs: tweak.Common.relToAbs
  # @property [Method] see tweak.Common.splitMultiName
  splitMultiName: tweak.Common.splitMultiName

  ###
    The constructor initialises the controllers unique ID, relating Component, its root and its initial config.
  ###
  constructor: (@component, @_config = {}) ->
    @root = @component.root
    @uid = "cp_#{tweak.uids.cp++}"

  ###
   Construct the Collection with given options from the configuration file
  ###
  init: ->
    @data = []
    data = []
    _name = @component.name or @_config.name
    for item in @_config
      obj = {}
      if item instanceof Array
        names = @splitMultiName _name, item[0]
        path = @relToAbs _name, item[1]
        for name in names
          @data.push new tweak.Component @, {name, extends:path}
      else if typeof item is "string"
        data = @splitMultiName _name, item
        for name in data
          @data.push new tweak.Component @, {name}
      else
        obj = item
        name = obj.name
        data = @splitMultiName _name, name
        obj.extends = @relToAbs _name, obj.extends
        for prop in data
          obj.name = prop
          @data.push new tweak.Component @, obj
      @data[@length++].init()

      # Remove @_config as the data is no longer required
      delete @_config
    return

  ###
    @private
    Rendering and re-rendering functionality to reduce code
  ###
  __componentRender: (type) ->
    if @length is 0
      @triggerEvent "ready"
    else
      @total = 0
      for item in @data
        item.controller.addEvent "ready", ->
          if ++@total is @length then @triggerEvent "ready"
        , 1, @
        item[type]()
    return

  ###
    Renders all of its Components, also triggers ready state when all Components are ready
  ###
  render: ->
    @__componentRender "render"
    return

  ###
    Re-render all of its Components, also triggers ready state when all Components are ready
  ###
  rerender: ->
    @__componentRender "rerender"
    return

  ###
    Find Component with matching data in model
    @param [String] property The property to find matching value against
    @param [*] value Data to compare to
    @return [Array] An array of matching Components
  ###
  whereData: (property, value) ->
    result = []
    componentData = @data
    for collectionKey, data of componentData
      modelData = data.model.data or model.data
      for key, prop of modelData when key is property and prop is value
        result.push data
    result

  ###
    Reset Components - clears the views

    @event changed Triggers a generic event that the store has been updated
  ###
  reset: ->
    for item in @data
      item.destroy()
    super()
    return

  ###
    There is no default import mechanism for this module - so set it to an empty function
  ###
  import: ->

  ###
    There is no default export mechanism for this module - so set it to an empty function
  ###
  export: ->