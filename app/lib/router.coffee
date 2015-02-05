###
  Router module
  @todo Document description
###

class tweak.Router
  # @property [Integer] The uid of this object - for unique reference
  uid: 0
  # @property [*] The root relationship to this module
  root: null
  # @property [*] The direct relationship to this module
  relation: null
  
  super: tweak.super

  # @private
  constructor: (relation, config = {}) ->
    # Set uid
    @uid = "r_#{tweak.uids.r++}"
    @relation = relation ?= {}
    @root = relation.root or @
    @name = config.name or relation.name

  ###
    Start watching the roouter for changes, options for speed and whether to be quiet
    @param [Object] options The listening options object
    @option options [Number] speed The amount of time per check in ms
    @option options [Boolean] quiet If true then it wont trigger events
  ###
  start: (options = {}) ->
    speed = options.speed or 50
    quiet = if options.quiet then true else false
    check = @check
    @watch = setInterval =>
      @check quiet
    , speed
    return
  
  ###
    Stop watching the router for changes
  ###
  stop: -> 
    clearInterval @watch
    return
  
  ###
    Check the window location, if there is an update from previous url then trigger an event
    @param [Boolean] quiet If true then it wont trigger events

    @example hash url examples
      tweakjs.com/#search/safe/version=2
      triggers:
        #{@uid}:data:search
        #{@uid}:data:safe
        #{@uid}:data:version (passes in 2)
        #{@uid}:changed (passes in {search:true, safe:true, version:2})

      tweakjs.com/#version:1/search/safe/version=2
      triggers:
        #{@uid}:data:version (passes in 1)
        #{@uid}:data:search
        #{@uid}:data:safe
        #{@uid}:data:version (passes in 2)
        #{@uid}:changed (passes in {search:true, safe:true, version:2})


    @note event name is made up from the data in the url. The router data is split up by / \ per data set, and by : = between the key and data.

    @event #{@name}:router:data:#{data key} Triggers an event based on the key value and if there is any data attached to the router key then that data is passed through aswell. Triggered for each data set
    @event #{@component.uid}:router:data:#{data key} Triggers an event based on the key value and if there is any data attached to the router key then that data is passed through aswell. Triggered for each data set
    @event #{@uid}:data:#{data key} Triggers an event based on the key value and if there is any data attached to the router key then that data is passed through aswell. Triggered for each data set

    @event #{@name}:router:changed Triggers an event and passes the data of the url back
    @event #{@component.uid}:router:changed Triggers an event and passes the data of the url back
    @event #{@uid}:changed Triggers an event and passes the data of the url back
  ###
  check: (quiet = false) ->
    hash = window.location.hash.substring 1
    data = 'data'
    if hash isnt @before
      hashObj = {}
      @before = hash
      if @ignore is true
        @ignore = false
        return
      @ignore = false

      for item in hash.split /[\\/]/
        itemArr = item.split /[=:]/
        if itemArr.length is 1
          hashObj[itemArr[0]] = true
          if not quiet then tweak.Common.__trigger @, "router:data:"+itemArr[0]
        else
          hashObj[itemArr[0]] = itemArr[1]
          if not quiet then tweak.Common.__trigger @, "router:data:"+itemArr[0], itemArr[1]
      if not quiet then tweak.Common.__trigger @, "router:changed", hashObj
    return
  
  ###
    Set the url hash with certain data; triggering router based events
    @param [Object] obj Simple object to pass into url. Can't be more than one level deep.
    @param [Boolean] quiet If true router events will not be triggered on change
  ###
  set: (obj, quiet = false) ->
    location = ''
    for key, item of obj
      if typeof(item) is 'boolean' and item
        location += "#{key}/"
      else
        location += "#{key}:#{item}/"
    @ignore = quiet
    window.location.hash = location.slice 0, -1
    return

  ###
    Masks the url hash with certain data without triggering events
    @param [Object] obj Simple object to pass into url. Can't be more than one level deep.
  ###
  mask: (obj) -> 
    @set obj, true
    return