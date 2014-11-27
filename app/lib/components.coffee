###
  The components collection is used to allow a component to have multiple sub components; allowing a extensive powerful heirachy system of components; which also allows for multiple areas of views.
  For example a view may have to sections of user interaction that does two different things and gets two different sets of data, but its parent view is about a particular item.
  This example shows the power of relations in the framework. As the two views are different with different data being fed in these can be two sub components, allowing seperation of code.
  This allow reloading of views without affect other views, a bit like regions in backbone marionette. However your code can now be much more structured in this format and easier to understand where things are happening.
###
class tweak.Components extends tweak.Collection
  # @property [String] The type of storage
  storeType: "components"
  # @property [Object] The config object of this module
  config: []
  # @property [*] The root relationship to this module
  root: null
  # @property [*] The direct relationship to this module
  relation: null

  reltoAbs: tweak.Common.relToAbs

  # @private
  constructor: (@relation, @config = {}) ->
    # Set uid
    @uid = "cp_#{tweak.uids.cp++}"

    @config = config or []
    @root = relation.root or @
    @name = config.name or relation.name
  
  ###
   Construct the Collection with given options from the config file
  ###
  init: ->
    @data = []
    data = []
    for item in @config or []
      obj = {}
      if item instanceof Array
        names = tweak.Common.splitComponents item[0], @name
        path = @relToAbs item[1], @name
        i = 0
        for name in names
          @data.push new tweak.Component @, {name, extends:path}
      else if typeof item is "string"
        if name is "" or name is " " then continue
        data = tweak.Common.splitComponents item, @name
        for name in data
          @data.push new tweak.Component @, {name}
      else
        obj = item
        name = obj.name
        if not name? or name is "" or name is " " then continue
        data = tweak.Common.splitComponents name, @name
        obj.extends = @relToAbs obj.extends, @name
        for prop in data
          obj.name = prop
          @data.push new tweak.Component @, obj

  ###
    @private
    Rendering and rererendering functionality to reduce code
  ###
  _componentRender: (type) ->
    if @length is 0
      tweak.Common.__trigger "#{@storeType}:ready"
      return
    total = 0
    totalItems = @length
    for item in @data
      item[type]()
      tweak.Events.on @, "#{item.uid}:view:#{type}ed", =>
        total++
        if total >= totalItems then tweak.Common.__trigger "#{@storeType}:ready"

  ###
    Renders all of its components, also triggers ready state when all components are ready
  ###
  render: -> @_componentRender "render"

  ###
    Rerender all of its components, also triggers ready state when all components are ready
  ###
  rerender: -> @_componentRender "rerender"

  ###
    Find component with matching data in model
    @param [String] property The property to find matching value against
    @param [*] value Data to compare to
    @return [Array] An array of matching components
  ###
  whereData: (property, value) ->
    result = []
    componentData = @data
    for collectionKey, data of componentData
      modelData = data.model.data or model.data
      for key, prop of modelData
        if key is property and prop is value then result.push data
    result

  ###
    Reset components - clears the views
  ###
  reset: ->
    for item in @data
      item.view?.clear()
    super()

  ###
    There is no default import mechanism for this module
  ###
  import: ->

  ###
    There is no default export mechanism for this module
  ###
  export: ->