###
----- Components -----

Needs to be refactored into two parts, collection and components
The collection should be usable to have a collection of anything like views, models and components.

###

class tweak.Components extends tweak.Collection
  of:'components'
  tweak.Extend(@, ['splitComponents', 'findModule', 'relToAbs'], tweak.Common)
  
  ###
    Description: Construct the Collection with given options from the config file
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
    Rendering functionality to reduce code
  ###
  componentRender = (type) ->
    if @length() is 0
      @trigger("#{@name}:#{@of}:ready")
      return
    total = 0
    totalItems = @data.length
    for item in @data
      item[type]()
      @on("#{item.name}:views:#{type}d", =>
        total++
        if total >= totalItems then @trigger("#{@name}:#{@of}:ready")
      )

  ###
    Description: Renders all of its components, also triggers ready state when all components are ready
  ###
  render: -> componentRender("render")

  ###
    Description: rerender all of its components, also triggers ready state when all components are ready
  ###
  rerender: -> componentRender("rerender")