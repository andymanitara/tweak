###
  The components collection is used to allow a component to have multiple sub components; allowing a extensive powerful heirachy system of components; which also allows for multiple areas of views.
  For example a view may have to sections of user interaction that does two different things and gets two different sets of data, but its parent view is about a particular item.
  This example shows the power of relations in the framework. As the two views are different with different data being fed in these can be two sub components, allowing seperation of code.
  This allow reloading of views without affect other views, a bit like regions in backbone marionette. However your code can now be much more structured in this format and easier to understand where things are happening.
  
  @include tweak.Common.Empty
  @include tweak.Common.Events
  @include tweak.Common.Collections
  @include tweak.Common.Arrays
  @include tweak.Common.Modules
  @include tweak.Common.Components

###
class tweak.Components extends tweak.Collection
  # @property [String] The type of storage
  storeType: "components"
  # @property [Object] The config object of this module
  config: []
  tweak.Extend(@, tweak.Common.Empty)
  tweak.Extend(@, tweak.Common.Events)
  tweak.Extend(@, tweak.Common.Collection)
  tweak.Extend(@, tweak.Common.Arrays)
  tweak.Extend(@, tweak.Common.Modules)
  tweak.Extend(@, tweak.Common.Components)
  
  ###
   Construct the Collection with given options from the config file
  ###
  construct: ->
    @data = []
    @history = []
    data = @splitComponents(@config.join(" "), @name)
    for key, prop of data
      if prop is "" or prop is " "
        delete data[key]
        continue
      data[key] = new tweak.Component(@, prop)
    
    for key, item of data
      @add item, {quiet:true, store:false}

  ###
    Rendering and rererendering functionality to reduce code
  ###
  _componentRender: (type) ->
    if @length is 0
      @trigger("#{@name}:#{@storeType}:ready")
      return
    total = 0
    totalItems = @length
    for item in @data
      item[type]()
      @on("#{item.name}:view:#{type}ed", =>
        total++
        if total >= totalItems then @trigger("#{@name}:#{@storeType}:ready")
      )

  ###
    Renders all of its components, also triggers ready state when all components are ready
  ###
  render: -> @_componentRender("render")

  ###
    Rerender all of its components, also triggers ready state when all components are ready
  ###
  rerender: -> @_componentRender("rerender")

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