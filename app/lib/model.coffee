###
  The model is simply a way of storing some data, with event triggering on changes to the model
  In common MVC concept the Model is not always a database. So the controller should be used to get data from a database.
  The controller is normally the interface between the view and the models data.
  When the model updates it will fire of events to Event system; allowing you to listen to what has been changed. The controller can then detirmine what to do when it gets updated.
  You can update the model quietly aswell.
  The model has its own history, so you can easily revert.

  @include tweak.Common.Empty
  @include tweak.Common.Events
  @include tweak.Common.Collections
###
class tweak.Model extends tweak.Store
  
  # @property [Object] Data storage holder, for a model this is an object
  data: {}
  # @property [Object] Default data to load into model when constructing the model
  default: {}
  # @property [String] The type of collection this is
  dataType: "model"
    
  ###
    Constructs the model ready for use
  ###
  construct: ->
    @reset()
    # Defaults are overriden completely when overriden by an extending model, however config model data is merged
    if @defaults? then @set @defaults, {quiet:true, store:false}
    data = @config or {}
    if data then @set data, {quiet:true, store:false}
  

  ###
    Remove a single property or many properties.
    @param [String, Array<String>] properties Array of property names to remove from model, or single String of the name of the property to remove
    @param [Object] options Options to detirmine extra functionality
    @option options [Boolean] store Decide whether to store the change to the history. Default: true
    @option options [Boolean] quiet Decide whether to trigger model events. Default: false

    @event #{@name}:model:removed:#{key} Triggers an event based on what property has been removed
    @event #{@name}:model:changed Triggers a generic event that the model has been updated
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
          @trigger "#{@name}:#{@storeType}:removed:#{key}"
    
    if store then @store()
    if not quiet then @trigger "#{@name}:#{@storeType}:changed"
    return
  
  ###
    Get an element at position of a given number
    @param [Integer] position Position of property to return
    @return [*] Returns data of property by given position
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
    Reset the model back to defaults
  ###
  reset: ->
    @data = {}
    @history = []