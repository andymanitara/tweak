###
  This class contains common shared functionality. The aim to reduce repeated code and overall filesize.
###
class tweak.Common
  ###
    Merge properites from object from one object to another. (First object is the object to take on the properties from other)
    @param [Object, Array] one The Object/Array to combine properties into.
    @param [Object, Array] two The Object/Array that shall be combined into the first object.
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
    @param [Object, Array] ref Reference object to clone.
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
      throw new Error "Unable to copy object its type isnt supported"

    # Handle Object
    for attr of ref
      if ref.hasOwnProperty(attr) then copy[attr] = @clone ref[attr]
    return copy

  ###
    Convert a simple JSON string/object.
    @param [JSONString, JSONObject] data JSONString/JSONObject to convert to vice versa.
    @param [Array<String>] restrict (Default = all properties get converted) Restrict which properties to convert. 
    @return [JSONObject, JSONString] Returns JSON data of the opposite data type
  ###
  parse: (data, restrict) ->
    _restrict = (obj) ->
      if not restrict?.length > 0 then return obj
      res = {}
      for item in restict
        res[item] = obj[item]
      res
    if typeof data is "string"
      _restrict JSON.parse data
    else
      JSON.stringify _restrict data

  ###
    Try to find a module by name in multiple paths. A final surrogate if available will be returned if no module can be found.
    @param [Array<String>] paths An array of context paths.
    @param [String] module The module path to convert to absolute path; based on the context path.
    @param [Object] surrogate (Optional) A surrogate Object that can be used if there is no module found.
    @return [Object] Returns an Object that has the highest piority.
    @throw When an object cannot be found and no surrogate is provided the following error message will appear - "Could not find a default module (#{module name}) for component #{component name}"
    @throw When an object is found but there is an error during processing the found object the following message will appear - "Module (#{path}) found. Encountered #{e.name}: #{e.message}"
  ###
  findModule: (contexts, module, surrogate = null) ->
    # Iterate each contex 
    for context in contexts
      # Convert path to absolute
      path = tweak.Common.relToAbs context, module
      try
        return require path
      catch e
        # If the error thrown isnt a direct call on "Error" Then the module was found however there was an internal error in the module
        if e.name isnt "Error"
          e.message = "Module (#{"#{path}"}) found. Encountered #{e.name}: #{e.message}"
          throw e
    return surrogate if surrogate?
    # If no paths are found then throw an error
    throw new Error "Could not find a default module (#{module}) for component #{contexts[0]}"

  ###
    Require method to find a module in a given context path and module path.
    The context path and module path are merged together to create an absolute path.
    @param [String] context The context path
    @param [String] module The module path to convert to absolute path, based on the context path
    @return [Object] Returns required object.
    @throw When module can not be loaded the following error message will appear - "Can not find path #{url}"
  ###
  require: (context, module) ->
    # Convert path to absolute path
    url = tweak.Common.relToAbs context, module
    try
      result = require url
    catch error
      throw new Error "Can not find path #{url}"
    result

  ###
    Convert relative path to an absolute path; relative path defined by ./ or .\
    It will also reduce the prefix path by one level per ../ in the path
    @param [String] context The context path
    @param [String] name The path to convert to absolute path, based on the context path
    @return [String] Absolute path
  ###
  relToAbs: (context, name) ->
    amount = module.split(/\.{2,}[\/\\]*/).length-1 or 0
    context = context.replace new RegExp("([\\\/\\\\]*[^\\\/\\\\]+){#{amount}}[\\\/\\\\]?$"), ''
    "/#{name}".replace /^(\.+[\/\\]*)+/, context

tweak.Common = new tweak.Common()