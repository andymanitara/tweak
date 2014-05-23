###
  ----- Common -----
  Common functions that are used in multiple places throughout the framework
  The aim of this is to reduce the size of the framework

  Listed with required functions:
    init
    construct
    require (relToAbs)
    relToAbs
    findModule (relToAbs)
    trigger
    on
    off
    clone
    reduced
    same
    combine
    splitComponents (relToAbs)

###
tweak.Common =
  ###
    Empty reusable functions
  ###
  init: ->
  construct: ->

  ###
    Parameters:   url:String, [params]
    Description:  If using require; this function will find the specified modules.
            This is used when building controllers and collections dynamically.
            It will try to find specified modules; or default to tweaks default objects
    returns: Object
  ###
  require: (url, params...) ->
    # Convert url to absolute path
    url = @relToAbs(url, @name)
    try
      result = require url
    catch error
      throw new Error "Can not find path #{url}"
    result

  ###
    Parameters:   path:String, prefix:String
    Description:  convert relative path to an absolute path, relative path defined by ./ or .\
    returns: String
  ###
  relToAbs: (path, prefix) -> path.replace(/^\.[\/\\]/, "#{prefix}/")

  ###
    Parameters:   paths:Array, module:String, surrogate:Object (optional)
    Description:  Try to find a module by name in multiple paths. If there is a surrogate, then if not found it will return this instead
    returns: Object
    throws: When cant be found and no surrogate is provided; when there is an error further down the scope.
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
    Description: Event trigger handler for DOM and the Event API
    *** Triggering a DOM EVENT ***
    Parameters: params...
                params[0]:domElement #element
                params[1]:String #type

    *** Triggering event from EVENT API ***
    Parameters: params...
                params[0]:String|Object(
                                  {
                                    name:String,
                                    context:String
                                  }
                                )
  ###
  trigger: (params...) ->
    setTimeout(=>
      if 1 is params[0].nodeType
        (@view or @).DOMtrigger params...
      else tweak.Events.trigger params...
    ,
    0)
    return

  ###
    Description: Event on handler for DOM and the Event API
    *** adding DOM EVENT ***
    Parameters: params...
                params[0]:domElement #element
                params[1]:String #type
                params[2]:function #callback

    *** adding event to EVENT API ***
    Parameters: params...
                params[1]:String #name
                params[2]:function #callback
                params[3]:maxCalls #optional
  ###
  on: (params...) ->
    if typeof params[0] is "string"
      tweak.Events.on @, params...
    else (@view or @).DOMon params...
    return

  ###
    Description: Event off handler for DOM and the Event API
    *** removing DOM EVENT ***
    Parameters: params...
                params[0]:domElement #element
                params[1]:String #type
                params[2]:function #callback

    *** removing event from EVENT API ***
    Parameters: params...
                params[1]:String #name
                params[2]:function #callback (optional)
                params[3]:maxCalls #optional


  ###
  off: (params...) ->
    if typeof params[0] is "string"
      tweak.Events.off @, params...
    else (@view or @).DOMoff params...
    return

  ###
    Parameters:   obj:(Object or Array)
    Description:  Clone an object to remove reference to original object or simply to copy it.
    Returns: Object
  ###
  clone: (obj) ->
    # Handle the 3 simple types, and null or undefined. returns itself if it tries to clone itslef otherwise it will stack overflow
    return obj if null is obj or "object" isnt typeof obj or obj is @

    # Handle Date
    if obj instanceof Date
      copy = new Date()
      copy.setTime obj.getTime()
      return copy

    # Handle Array
    if obj instanceof Array
      copy = []
      i = 0
      len = obj.length

      while i < len
        copy[i] = @clone(obj[i])
        i++
      return copy

    # Handle Object
    if obj instanceof Object
      copy = {}
      for attr of obj
        copy[attr] = @clone(obj[attr])  if obj.hasOwnProperty(attr)
      return copy
    throw new Error("Unable to copy object its type isnt supported")

    return

  ###
    Parameters:   arr:Array
    Description:  Reduce an array be remove elements from the front of the array and returning the new array
    returns: Array
  ###
  reduced: (arr, length) ->
    start = arr.length - length
    for [start..length] then arr[_i]

  ###
    Parameters:   one:Object, two:Object
    Description:  Check if object is the same
    returns: Boolean
  ###
  same: (one, two) ->
    for key, prop of one
      if not two[key]? or two[key] isnt prop then return false
    return true


  ###
    Parameters:   one:Object, two:Object
    Description:  merge properites from object two into object one
    returns: Object
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
    Parameters:   str:String, name:String
    Description:  Reduce component names like ./cd[0-98] to an array of full path names
    returns: Array of Strings
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