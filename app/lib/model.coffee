###
  ----- MODEL -----
  The model is simply a way of storing some data, with event triggering on changes to the model
  In common MVC concept the Model is not always a database. So the controller should be used to get data from a database.
  The controller is normally the interface between the view and the models data.
  When the model updates it will fire of events to Event system; allowing you to listen to what has been changed. The controller can then detirmine what to do when it gets updated.
  You can update the model quietly aswell.
  The model has its own history, so you can easily revert.
###
class tweak.Model
  length: 0
  
  tweak.Extend(@, ['trigger', 'on', 'off', 'clone', 'reduced', 'same'], tweak.Common)
  init: ->

  construct: ->
    @data = {}
    @history = []
    # Defaults are overriden completely when overriden by an extending model, however config model data is merged
    if @defaults? then @set @defaults, {quiet:true, store:false}
    data = @config or {}
    if data then @set data, {quiet:true, store:false}
  
  ###
    Parameters:   property:String
    Description:  returns whether or not the object exists or not
  ###
  has: (property) -> @data[property]?
  
  ###
    Parameters:   property:String
    Description:  Get a models property
  ###
  get: (property) -> @data[property]
  
  ###
    Parameters:   properties: object, [params]
    Description:  Set multiple properties or one property of the model by passing an object with object of the data you with to update.
                  Pass options to control extra functionality
                    quiet:Boolean to set whether to do it quiet or not. Default is false.
                    store:Boolean is to set whether to store this change to the history. Default is true
                  Each property set triggers an event. And triggers an event that the model has changed.
  ###
  set: (properties, params...) ->
    options = params[0]
    if typeof properties is 'string'
      prevProps = properties
      properties = {}
      properties[prevProps] = params[0]
      options = params[1]
    options or= {}
    store = if options.store? then options.store else true
    quiet = options.quiet
    if store then @store()
    for key, prop of properties
      @data[key] = prop
      @length++
      if not quiet then @trigger "#{@name}:model:changed:#{key}", prop

    if not quiet then @trigger "#{@name}:model:changed"

    return

  ###
    Parameters:   properties:Object or String, options:Object
    Description:  Remove a single property or many properties.
                  Pass options to control extra functionality
                    quiet:Boolean to set whether to do it quiet or not. Default is false.
                    store:Boolean  is to set whether to store this change to the history. Default is true
                  Each property removed triggers an event. And and triggers an event that the model has changed.
  ###
  remove: (properties, options = {}) ->
    store = if options.store? then true else false
    quiet = options.quiet
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      for key, prop of data
        if key is property
          @length--
          delete @data[key]
          @trigger "#{@name}:model:removed:#{key}"
    
    if store then @store()
    if not quiet then @trigger "#{@name}:model:changed"
    return
  
  ###
    Description:  Revert the model back to previous state in history, default is one previous version
  ###
  revert: (params...) ->
    if typeof params[0] is 'object' then options = params[0]
    else
      amount = params[0]
      options = params[1]
    options or= {}
    amount ?= 1
    history = @history
    historyLength = history.length
    if amount > historyLength then amount = historyLength
    state = history[historyLength - amount]
    @data = {}
    @set @clone(state), options
    return
  
  ###
    Description:  Returns the changed properties between the current model and a previous model state. Default is one state behind.
  ###
  changed: (position) ->
    position ?= 1
    if position > @history.length then position = @history.length
    state = @history[@history.length - position]
    data = @data
    results = {}
    for key, prop of data
      if not state[key]? then results[key] = prop
      for prevKey, prevProp of state
        if not data[prevKey]? then results[prevKey] = prevProp
        if key is prevKey
          if prop isnt prevProp then results[key] = prevProp
    results
  
  ###
    description:   Store the models data to the history
  ###
  store: ->
    @history.push(@clone @data)
    memLength = @relation.memoryLength
    history = @history
    historyLength = history.length
    if memLength? and memLength < historyLength then @reduced(memLength)
    return
  
  ###
    description:  Reset the model back to defaults
  ###
  reset: (options = {}) ->
    @data = {}
    @history = []
    @construct()
    return

  ###
    Description: Get an element ad position of
  ###
  at: (position) ->
    position = Number(position)
    data = @data
    i = 0
    for key, prop of data
      if i is position then return data[key]
      i++

    null
  
  ###
    Description:
  ###
  removeAt: (position, options = {}) ->
    element = @at position
    for key, prop of element
      @remove key, options
    return
  
  ###
    Description:
  ###
  where: (value) ->
    result = []
    data = @data
    for key, prop of data
      if prop is value then result.push prop
    return result