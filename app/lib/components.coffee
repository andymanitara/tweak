###
  The components collection is used to allow a component to have multiple sub components; allowing a extensive powerful heirachy system of components; which also allows for multiple areas of views.
  For example a view may have to sections of user interaction that does two different things and gets two different sets of data, but its parent view is about a particular item.
  This example shows the power of relations in the framework. As the two views are different with different data being fed in these can be two sub components, allowing seperation of code.
  This allow reloading of views without affect other views, a bit like regions in backbone marionette. However your code can now be much more structured in this format and easier to understand where things are happening.
###
class tweak.Components extends tweak.Collection
  # Not using own tweak.extends method as codo doesnt detect that this is an extending class
    
  # @property [String] The type of storage
  _type: "components"

  # @property [Method] see tweak.Common.relToAbs
  relToAbs: tweak.Common.relToAbs

  ###
    The constructor initialises the controllers unique ID, relating component, its root and its initial config. 
  ###
  constructor: (@component, @_config = {}) -> 
    @root = @component.root
    @uid = "cp_#{tweak.uids.cp++}"

  ###
    Split a component name out to individual absolute component names. 
    Names formated like "./cd[2-4]" will return an array or something like ["album1/cd2","album1/cd3","album1/cd4"].
    Names formated like "./cd[2-4]a ./item[1]/model" will return an array or something like ["album1/cd2a","album1/cd3a","album1/cd4a","album1/item0/model","album1/item1/model"].
    @param [String] context The current context's relating name
    @param [String, Array<String>] names The string to split into seperate component names
    @return [Array<String>] Returns Array of absolute module names
  ###
  __splitMultiName: (context, names) ->
    values = []
    # Regex to split out the name prefix, suffix and the amount to expand by
    reg = /^(.*)\[(\d*)(?:[,\-](\d*)){0,1}\](.*)$/

    # Split name if it is a string
    if typeof names is "string"
      names = names.split /\s+/

    # Iterate through names in 
    for item in names
      result = reg.exec item
      # If regex matches then expand the name 
      if result?
        prefix = result[1]
        min = result[2] or 0
        max = result[3] or min
        suffix = result[4]    
        while min <= max
          values.push @relToAbs context, "#{prefix}#{min++}#{suffix}"
      else
        values.push @relToAbs context, item
    values
  
  ###
   Construct the Collection with given options from the config file
  ###
  init: ->
    @data = []
    data = []
    _name = @component.name or @_config.name
    for item in @_config
      obj = {}
      if item instanceof Array
        names = @__splitMultiName _name, item[0]
        path = @relToAbs _name, item[1]
        for name in names
          @data.push new tweak.Component @, {name, extends:path}
      else if typeof item is "string"
        data = @__splitMultiName _name, item
        for name in data
          @data.push new tweak.Component @, {name}    
      else
        obj = item
        name = obj.name
        data = @__splitMultiName _name, name
        obj.extends = @relToAbs _name, obj.extends
        for prop in data
          obj.name = prop
          @data.push new tweak.Component @, obj
      @data[@length++].init()

      # Remove config as the data is no longer required
      delete @_config
    return

  ###
    @private
    Rendering and rererendering functionality to reduce code
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
    Renders all of its components, also triggers ready state when all components are ready
  ###
  render: -> 
    @__componentRender "render"
    return

  ###
    Rerender all of its components, also triggers ready state when all components are ready
  ###
  rerender: -> 
    @__componentRender "rerender"
    return

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
      for key, prop of modelData when key is property and prop is value
        result.push data
    result

  ###
    Reset components - clears the views

    @event changed Triggers a generic event that the store has been updated
  ###
  reset: ->
    for item in @data
      item.destroy()
    super()
    return

  ###
    There is no default import mechanism for this module
  ###
  import: ->

  ###
    There is no default export mechanism for this module
  ###
  export: ->