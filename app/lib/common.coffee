class tweak.Common
  ###
    Triggering API Events
    Trigger name, component uid and uid events
    @param [String] name The event name; split on the / and : characters
    @param [...] params Params to pass into the callback function
  ###
  ___trigger: (path, args...) ->
    secondary = path.split ":"
    secondary.shift()
   	setTimeout(->
      tweak.Events.trigger "#{@name}:#{path}", args...
    ,0)
   	setTimeout(->
       tweak.Events.trigger "#{@cuid}:#{path}", args...
    ,0)
   	setTimeout(->
       tweak.Events.trigger "#{@uid}:#{secondary.join ':'}", args...
    ,0)

  ###
    Reduce component names like ./cd[0-98] to an array of full path names
    @param [String] str The string to split into seperate component names
    @param [String] name The name to which the relative path should become absolute to
    @return [Array<String>] Returns Array of full path names
  ###
  splitComponents: (str, name) ->
    values = []
    arrayRegex = /^(.*)\[((\d*)\-(\d*)|(\d*))\]$/
    for item in str.split " "
      if item is " " then continue
      name = name or @component.name
      item = tweak.Common.relToAbs item, name
      result = arrayRegex.exec item
      if result
        prefix = result[1]
        min = 1
        max = result[5]
        if not max?
          min = result[3]
          max = result[4]
        for i in [min..max]
          values.push "#{prefix}#{i}"
      else values.push item
    values

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
        one[key] = @combine one[key], prop
      else
        one[key] = prop
    one

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
    else if typeof ref is "object"
      copy = {}
    else
      throw new Error("Unable to copy object its type isnt supported")

    # Handle Object
    for attr of ref
      copy[attr] = @clone(ref[attr]) if ref.hasOwnProperty attr
    return copy

  ###
    Convert a simple JSON string/object
    @param [JSONString, JSONObject] data JSON data to convert.
    @param [Array<String>] restrict Restrict which properties to convert. Default: all properties get converted.
    @return [JSONObject, JSONString] Returns JSON data of the opposite data type
  ###
  parse: (data, restrict) ->
    _restrict = (obj) ->
      if not restrict then return obj
      res = {}
      for item in restict
        res[item] = obj[item]
      res
    if typeof data is string
      _restrict JSON.parse data
    else
      JSON.stringify _restrict data

  ###
    Try to find a module by name in multiple paths. If there is a surrogate, then if not found it will return this instead
    @param [Array<String>] paths An Array of Strings, the array contains paths to which to search for objects. The lower the key value the higher the piority
    @param [String] module The name of the module to search for
    @param [String] name The name to which the relative path should become absolute to
    @param [Object] surrogate (Optional) A surrogate Object that can be used if there is no module found.
    @return [Object] Returns an Object that has the highest piority.
    @throw When an object cannot be found and no surrogate is provided the following error message will appear - "Could not find a default module (#{module name}) for component #{component name}"
    @throw When an object is found but there is an error during processing the found object the following message will appear - "Found module (#{Module Name}) for component #{Component Name} but there was an error: #{Error Message}"
  ###
  findModule: (paths, module, name, surrogate = null) ->
    for path in paths
      path = tweak.Common.relToAbs path, name
      try
        return require "#{path}/#{module}"
      catch e
        ###
          If the error thrown isnt a direct call on "Error" Then the module was found however there was an internal error in the module
        ###
        if e.name isnt "Error"
          e.message = "Module (#{"#{path}/#{module}"}) found although encountered #{e.name}: #{e.message}"
          throw e

        

    return surrogate if surrogate?
    # If no paths are found then throw an error
    throw new Error "Could not find a default module (#{module}) for component #{paths[0]}"

  ###
    If using require; this function will find the specified modules.
    This is used when building controllers and collections dynamically.
    It will try to find specified modules; or default to tweaks default object

    @param [String] path The path to require with module loader
    @param [String] name The name to which the relative path should become absolute to
    @return [Object] Returns required object
    @throw When module can not be loaded the following error message will appear - "Can not find path #{path}"
  ###
  require: (path, name) ->
    # Convert path to absolute path
    url = tweak.Common.relToAbs path, name
    try
      result = require url
    catch error
      throw new Error "Can not find path #{url}"
    result


  ###
    convert relative path to an absolute path, relative path defined by ./ or .\
    @note Might need a better name cant think of better though.
    @param [String] path The relative path to convert to absolute path
    @param [String] prefix The prefix path
    @return [String] Absolute path
  ###
  relToAbs: (path, prefix) -> path.replace /^\.[\/\\]/, "#{prefix}/"

tweak.Common = new tweak.Common()