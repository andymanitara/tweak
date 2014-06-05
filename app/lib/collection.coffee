###
  collection
###
class tweak.Collection extends tweak.Model

  ###
    @note comment
  ###
  construct: ->
    @data = []
    @history = []

  ###
    @param []
    @param []
  ###
  build: (relation, data) ->
    @component = @relation = relation
    @config = data
    @name ?= @component.name
    @construct()
  
  ###
    @param []
    @option
    @return []
  ###
  pop: (options = {}) ->
    result = @data[@length()-1]
    @remove result, options
    return result
  
  ###
    @param []
    @param []
    @option
  ###
  add: (data, options = {}) -> @set "#{@length}", data, options
  
  ###
    @param []
    @param []
    @param []
    @option
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
    for data in @datas
      if _j < position then continue
      result.push @data[_j]
    @data = result
    if store then @store()
    if not quiet
      @trigger "#{@name}:#{@of}:changed"
      @trigger "#{@name}:#{@of}:changed:#{position}"
    return
  
  ###
    @param []
    @return []
  ###
  pluck: (property) ->
    result = []
    for prop in @data
      if prop is property then result.push prop
    return result

  ###
    @param []
    @param []
    @return []
  ###
  whereData: (property, value) ->
    result = []
    componentData = @data
    for collectionKey, data of componentData
      modelData = data.model.data or model.data
      for key, prop of modelData
        if key is property and prop is value then result.push data
    return result

  ###
    @param []
    @param []
    @option
  ###
  remove: (properties, options = {}) ->
    store = if options.store? then true else false
    quiet = options.quiet
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      delete @data[property]
      @trigger "#{@name}:#{@of}:removed:#{property}"
    
    @sort()
    if store then @store()
    if not quiet then @trigger "#{@name}:#{@of}:changed"
    return
    
  ###
    @note comment
  ###
  sort: ->
    result = []
    for key, item of @data
      result[result.length] = item
    @data = result