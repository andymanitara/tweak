###
  Common functions that are used in multiple places throughout the framework
  The aim of this is to reduce the size of the framework

  @mixin
###
tweak.Common =
  ###
    Clone an object to remove reference to original object or simply to copy it.
    @param [Object, Array] ref Reference object to clone
    @return [Object, Array] Returns the copied object, while removing object references.
  ###
  clone: (ref) ->
    # Handle the 3 simple types, and null or undefined. returns itself if it tries to clone itslef otherwise it will stack overflow
    return ref if null is ref or "object" isnt typeof ref or ref is @

    # Handle Date
    if ref instanceof Date
      copy = new Date()
      copy.setTime ref.getTime()
      return copy

    # Handle Array
    if ref instanceof Array
      copy = []
      i = 0
      len = ref.length

      while i < len
        copy[i] = @clone(ref[i])
        i++
      return copy

    # Handle Object
    if ref instanceof Object
      copy = {}
      for attr of ref
        copy[attr] = @clone(ref[attr])  if ref.hasOwnProperty(attr)
      return copy
    throw new Error("Unable to copy object its type isnt supported")

    return

  ###
    Merge properites from object from one object to another. (Reversed first object is the object to take on the properties from another)
    @param [Object, Array] one The Object/Array to combine properties into
    @param [Object, Array] two The Object/Array that shall be combined into the first object
    @return [Object, Array] Returns the resulting combined object from two Object/Array
  ###
  combine: (one, two) ->
    for key, prop of two
      if typeof prop is 'object'
        one[key] ?= if prop instanceof Array then [] else {}
        one[key] = @combine(one[key], prop)
      else
        one[key] = prop
    one

  ###
    Empty reusable function
  ###
  construct: ->

  ###
    Try to find a module by name in multiple paths. If there is a surrogate, then if not found it will return this instead
    @param [Array<String>] paths An Array of Strings, the array contains paths to which to search for objects. The lower the key value the higher the piority
    @param [String] module The name of the module to search for
    @param [Object] surrogate (Optional) A surrogate Object that can be used if there is no module found.
    @return [Object] Returns an Object that has the highest piority.
    @throw When an object cannot be found and no surrogate is provided the following error message will appear - "Could not find a default module (#{module name}) for component #{component name}"
    @throw When an object is found but there is an error during processing the found object the following message will appear - "Found module (#{Module Name}) for component #{Component Name} but there was an error: #{Error Message}"
  ###
  findModule: (paths, module, surrogate = null) ->
    for path in paths
      path = @relToAbs(path, @name)
      try
        return require "#{path}/#{module}"
      catch e
        ###
          Detirmine if the error is to do with module not being found
          switch statement probably needed for supporting other error messages made by other module loaders
        ###
        reg = /["]([^"]*)["]\B$/
        regResult = reg.exec(e.message)
        errorPath = regResult[1] if regResult
        if e.message isnt "Cannot find module \"#{path}/#{module}\" from \"#{errorPath}\""
          e.message = "Found module (#{module}) for component #{@name} but there was an error: #{e.message}"
          throw e

    return surrogate if surrogate?
    # If no paths are found then throw an error
    throw new Error "Could not find a default module (#{module}) for component #{paths[0]}"

  ###
    Empty reusable function
  ###
  init: ->

  ###
    Event 'off' handler for DOM and the Event API
    @overload off(element, type, callback)
      Removing Dom Event
      @param [DomElement, String] element A DomElement object that an event is applied to or if using a selector engine pass a string with the selector based query (Selects object based on the el property of the view)
      @param [String] type The type of event (For example "click")
      @param [Function] callback The callback function

    @overload off(name, callback)
      Removing event from the Event Api
      @param [String] name The event name, split on the / and : characters, to remove
      @param [Function] callback (optional) The callback function; if you do not include this then all events under the name will be removed
      @return [Boolean] Returns whether the event is removed
  ###
  off: (params...) ->
    if params[2]? then (@view or @).DOMoff params...
    else tweak.Events.off @, params...

  ###
    Event 'on' handler for DOM and the Event API
    @overload on(element, type, callback)
      Adding Dom Event
      @param [DomElement, String] element A DomElement object to apply event to, or if using a selector engine pass a string with the selector based query (Selects object based on the el property of the view)
      @param [String] type The type of event (For example "click")
      @param [Function] callback The callback function

    @overload on(name, callback, maxCalls)
      Adding event from the Event API
      @param [String] name The event name, split on the / and : characters, to add
      @param [Function] callback  The callback function; if you do not include this then all events under the name will be removed
      @param [Number] maxCalls The maximum amount of calls the event can be triggered.
      @return [Boolean] Returns whether the event is added
  ###
  on: (params...) ->
    if typeof params[1] is "string"
      (@view or @).DOMon params...
    else tweak.Events.on @, params...

  ###
    Reduce an array be remove elements from the front of the array and returning the new array
    @param [Array] arr Array to reduce
    @param [Number] length The length that the array should be
    @return [Array] Returns reduced array
  ###
  reduced: (arr, length) ->
    start = arr.length - length
    for [start..length] then arr[_i]

  ###
    convert relative path to an absolute path, relative path defined by ./ or .\
    @note Might need a better name cant think of better though.
    @param [String] path The relative path to convert to absolute path
    @param [String] prefix The prefix path
    @return [String] Absolute path
  ###
  relToAbs: (path, prefix) -> path.replace(/^\.[\/\\]/, "#{prefix}/")


  ###
    If using require; this function will find the specified modules.
    This is used when building controllers and collections dynamically.
    It will try to find specified modules; or default to tweaks default object

    @param [String] path The path to require with module loader
    @return [Object] Returns required object
    @throw When module can not be loaded the following error message will appear - "Can not find path #{path}"
  ###
  require: (path) ->
    # Convert path to absolute path
    url = @relToAbs(path, @name)
    try
      result = require url
    catch error
      throw new Error "Can not find path #{url}"
    result

  ###
    Returns whether two object are the same (similar)
    @param [Object, Array] one Object to compare
    @param [Object, Array] two Object to compare
    @return [Boolean] Returns whether two object are the same (similar)
  ###
  same: (one, two) ->
    for key, prop of one
      if not two[key]? or two[key] isnt prop then return false
    return true

  ###
    Reduce component names like ./cd[0-98] to an array of full path names
    @param [String] str The string to split into seperate component names
    @param [String] name The name to which the relative path should become absolute to
    @return [Array<String>] Returns Array of full path names
  ###
  splitComponents: (str, name) ->
    values = []
    arrayRegex = /^(.*)\[((\d*)\-(\d*)|(\d*))\]$/
    for item in str.split(" ")
      if item is " " then continue
      name = name or @parentName or @relation.parentName or @name
      item = @relToAbs(item, name)
      result = arrayRegex.exec(item)
      if result
        prefix = result[1]
        min = 1
        max = result[5]
        if not max?
          min = result[3]
          max = result[4]
        for i in [min..max]
          values.push("#{prefix}#{i}")
      else values.push item
    values

  ###
    Event 'trigger' handler for DOM and the Event API, triggered in async
    @todo Think of a way to get DOM Event trigger to accept string aswell
    @overload trigger(name, params)
      Triggering Dom Event
      Trigger events by name only
      @param [String] name The event name; split on the / and : characters
      @param [...] params Params to pass into the callback function

    @overload trigger(obj, params)
      Triggering Dom Event
      Trigger events by name and context
      @param [Object] obj {name:String (name of the event), context:Object (context of the event)}
      @param [...] params Params to pass into the callback function
    
    @overload trigger(element, type)
      Triggering event from the Event API
      @param [DomElement] element A DomElement object to apply event to
      @param [String] type The type of event (For example "click")
  ###
  trigger: (params...) ->
    setTimeout(=>
      if 1 is params[0].nodeType
        (@view or @).DOMtrigger params...
      else tweak.Events.trigger params...
    ,
    0)
    return