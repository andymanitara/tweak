###
  This class contains common shared functionality. The aim to reduce repeated code.
###
class tweak.Common
  ###
    Triggering API calls in one hit - to reduce repetative code.
    @param [*] ctx The context of the function
    @param [String] name The event name; split on / and : characters
    @param [...] args Callback function parameters
  ###
  __trigger: (ctx, path, args...) ->
    secondary = path.split ":"
    secondary.shift()
    setTimeout(->
      tweak.Events.trigger "#{ctx.name}:#{path}", args...
    ,0)
    if ctx.cuid?
      setTimeout(->
        tweak.Events.trigger "#{ctx.cuid}:#{path}", args...
      ,0)
    setTimeout(->
      tweak.Events.trigger "#{ctx.uid}:#{secondary.join ':'}", args...
    ,0)

  ###
    Reduce component names like ./cd[0-98] to an array of all the module names
    @param [String] str The string to split into seperate component names
    @return [Array<String>] Returns Array of absolute module names
  ###
  splitModuleName: (context, str) ->
    values = []
    reg1 = /\[(\d*)\-(\d*)\]$/
    reg2 = /\[(\d*)\]$/
    reg3 = /^(.*)\[/
    for item in str.split " "
      prefix = reg3.exec(item)
      if prefix
        prefix = prefix[1]
        min = 0
        max = 0
        if item.match reg2
          max = reg2.exec(item)[1]
        else if item.match reg1
          result = reg1.exec item
          min = result[1]
          max = result[2]     
        
        while min <= max
          values.push tweak.Common.relToAbs context, "./#{prefix}#{min++}"
      else
        values.push tweak.Common.relToAbs context, str
    values

  ###
    Merge properites from object from one object to another. (First object is the object to take on the properties from another)
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
    @param [JSONString, JSONObject] data JSON data to convert.
    @param [Array<String>] restrict Restrict which properties to convert. Default: all properties get converted.
    @return [JSONObject, JSONString] Returns JSON data of the opposite data type.
  ###
  parse: (data, restrict) ->
    _restrict = (obj) ->
      if not restrict?.length > 0 then return obj
      res = {}
      for item in restict
        res[item] = obj[item]
      res
    if typeof data is string
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
    for context in contexts
      path = tweak.Common.relToAbs context, module
      try
        return require path
      catch e
        ###
          If the error thrown isnt a direct call on "Error" Then the module was found however there was an internal error in the module
        ###
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
    @param [String] module The module path to convert to absolute path; based on the context path
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
    convert relative path to an absolute path; relative path defined by ./ or .\
    It will also reduce the prefix path by one level per ../ in the path
    @param [String] context The context path
    @param [String] module The module path to convert to absolute path; based on the context path
    @return [String] Absolute path to the module
  ###
  relToAbs: (context, module) ->
    amount = module.split(/\.{2,}[\/\\]/).length-1 or 0
    context = context.replace new RegExp("([\\\/\\\\]?[^\\\/\\\\]+){#{amount}}[\\\/\\\\]?$"), ''
    module = module.replace /^(\.+[\/\\])+/, "#{context.replace /[\/\\]*$/, '/'}"
    module.replace /^[\/\\]+/, ''

tweak.Common = new tweak.Common()