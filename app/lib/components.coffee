### 
----- Components -----

Needs to be refactored into two parts, collection and components
The collection should be usable to have a collection of anything like views, models and components. 

###   

class tweak.Components extends tweak.Collection
  extend(@, ['require','splitComponents', 'findModule', 'relToAbs'], Common)
  ### 
    Parameters: data:Object 
    Description: Construct the Collection with given options  
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

  build: (relation, data) ->
    @component = @relation = relation
    @config = data 
    @name ?= @component.name
    @construct()
  
  ### 
    Description:      
  ###
  pop: (options = {}) ->
    result = @data[length()-1]
    @remove result, options
    return result
  
  ### 
    Description:      
  ###
  add: (data, options = {}) ->
    @set "#{@length()}", data, options
  
  ### 
    Description:      
  ###
  place: (data, position, options = {}) ->
    options.data = options.data or {}
    quiet = @options.quiet
    store = if options.store? then true else false
    result = []
    for prop in @data
      if position is _i then break
      result.push @data[_i]
    result.push data
    for data in @data
      if _j < position then continue
      result.push @data[_j]
    @data = result
    if store then @store()
    if not quiet 
      @trigger "#{@name}:components:changed"
      @trigger "#{@name}:components:changed:#{position}"
    return
  
  ### 
    Description:      
  ###
  pluck: (property) ->
    result = []
    for prop in @data
      if prop is property then result.push prop
    return result

  ###   
    Description:  
  ###
  whereData: (property, value) ->
    result = []
    componentData = @data
    for collectionKey, data of componentData
      modelData = data.model.data or model.data
      for key, prop of modelData
        if key is property and prop is value then result.push data
    return result

  remove: (properties, options = {}) ->
    store = if options.store? then true else false
    quiet = options.quiet
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      delete @data[property]
      @trigger "#{@name}:components:removed:#{property}"
    
    @sort()
    if store then @store()
    if not quiet then @trigger "#{@name}:components:changed"
    return

  sort: ->
    result = []
    for key, item of @data
      result[result.length] = item 
    @data = result

  render: ->
    if @length() is 0
      @trigger("#{@name}:components:ready")
      return
    total = 0
    totalItems = @data.length
    for item in @data
      item.controller.render()
      @on("#{item.name}:view:rendered", =>
        total++
        if total >= totalItems then @trigger("#{@name}:components:ready")
      )

  rerender: ->
    if @length() is 0
      @trigger("#{@name}:components:ready")
      return
    total = 0
    totalItems = @data.length
    for item in @data
      item.controller.rerender()
      @on("#{item.name}:view:rendered", =>
        total++
        if total >= totalItems then @trigger("#{@name}:components:ready")
      )
