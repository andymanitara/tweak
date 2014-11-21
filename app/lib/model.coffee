###
  The model is simply a way of storing some data, with event triggering on changes to the model
  In common MVC concept the Model is not always a database. So the controller should be used to get data from a database.
  The controller is normally the interface between the view and the models data.
  When the model updates it will fire of events to Event system; allowing you to listen to what has been changed. The controller can then detirmine what to do when it gets updated.
  You can update the model quietly aswell.

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
  storeType: "model"

  tweak.Extend @, [
    tweak.Common.Empty,
    tweak.Common.Events,
    tweak.Common.JSON
  ]


  # @private
  constructor: ->
    # Set uid
    @uid = "m_#{tweak.uids.m++}"
    
  ###
    Constructs the model ready for use
  ###
  construct: ->
    @reset()
    # Defaults are overriden completely when overriden by an extending model, however config model data is merged
    if @defaults? then @set @defaults, true
    data = @config or {}
    if data then @set data, true
  

  ###
    Remove a single property or many properties.
    @param [String, Array<String>] properties Array of property names to remove from model, or single String of the name of the property to remove
    @param [Boolean] quiet Setting to trigger change events

    @event #{@name}:model:removed:#{key} Triggers an event based on what property has been removed
    @event #{@component.uid}:model:removed:#{key} Triggers an event based on what property has been removed
    @event #{@uid}:removed:#{key} Triggers an event based on what property has been removed

    @event #{@name}:model:changed Triggers a generic event that the model has been updated
    @event #{@component.uid}:model:changed Triggers a generic event that the model has been updated
    @event #{@uid}:model:changed Triggers a generic event that the model has been updated
  ###
  remove: (properties, quiet = true) ->
    if typeof properties is 'string' then properties = [properties]
    for property in properties
      for key, prop of data
        if key is property
          @length--
          delete @data[key]
          if not quiet then @__trigger "#{@storeType}:removed:#{key}"

    if not quiet then @__trigger "#{@storeType}:changed"
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

  import: (data, options = {}) -> @set @parse(data, options.restict), options.quiet

  export: (restrict) -> @parse @data, restrict