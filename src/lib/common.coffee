###
  This class contains common shared functionality. The aim to reduce repeated code
  and overall file size of the framework.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
###
class Tweak.Common
  
  ###
    Merge properties from object from one object to another. (First object is the object to take on the properties from the second object).
    @param [Object, Array] one The Object/Array to combine properties into.
    @param [Object, Array] two The Object/Array that shall be combined into the first object.
    @return [Object, Array] Returns the resulting combined object from two Object/Array.
  ###
  @combine = (one, two) ->
    for key, prop of two
      if typeof prop is 'object'
        one[key] ?= if prop instanceof Array then [] else {}
        one[key] = Tweak.Common.combine one[key], prop
      else
        one[key] = prop
    one

  ###
    Clone an object to remove reference to original object or simply to copy it.
    @param [Object, Array] ref Reference object to clone.
    @return [Object, Array] Returns the copied object, while removing object references.
  ###
  @clone = (ref) ->
    # Handle the 3 simple types, and null or undefined. Peturns itself if it tries to clone itself otherwise it will stack overflow
    return ref if null is ref or 'object' isnt typeof ref or ref is @

    # Handle Date
    if ref instanceof Date
      copy = new Date()
      copy.setTime ref.getTime()
      return copy

    # Handle Array
    if ref instanceof Array
      copy = []
    else if typeof ref is 'object'
      copy = {}
    else
      throw new Error 'Unable to copy object, type not supported.'

    # Handle Object
    for attr of ref
      if ref.hasOwnProperty(attr) then copy[attr] = Tweak.Common.clone ref[attr]
    return copy

  ###
    Convert a simple JSON string/object.
    @param [JSONString, JSONObject] data JSONString/JSONObject to convert to vice versa.
    @return [JSONObject, JSONString] Returns JSON data of the opposite data type
  ###
  @parse = (data) -> JSON[if typeof data is 'string' then 'parse' else 'stringify'] data

  ###
    Try to find a module by name in multiple paths. A final surrogate if available will be returned if no module can be found.
    @param [Array<String>] paths An array of context paths.
    @param [String] module The module path to convert to absolute path; based on the context path.
    @param [Object] surrogate (Optional) A surrogate Object that can be used if there is no module found.
    @return [Object] Returns an Object that has the highest priority.
    @throw When an object cannot be found and no surrogate is provided the following error message will appear -
      "No default module (#{module name}) for component #{component name}".
    @throw When an object is found but there is an error during processing the found object the following message will appear -
      "Module (#{path}) found. Encountered #{e.name}: #{e.message}".
  ###
  @findModule = (contexts, module, surrogate) ->
    # Iterate each context
    for context in contexts
      # Convert path to absolute
      try
        return Tweak.Common.require context, module
      catch e
        # If the error thrown isn't a direct call on 'Error' Then the module was found however there was an internal error in the module
        if e.name isnt 'Error'
          e.message = "Module (#{context}}) found. Encountered #{e.name}: #{e.message}"
          throw e
    return surrogate if surrogate?
    # If no paths are found then throw an error
    throw new Error "No default module (#{module}) for component #{contexts[0]}"

  ###
    Require method to find a module in a given context path and module path.
    The context path and module path are merged together to create an absolute path.
    @param [String] context The context path.
    @param [String] module The module path to convert to absolute path, based on the context path.
    @param [Object] surrogate (Optional) A surrogate Object that can be used if there is no module found.
    @return [Object] Required object or the surrogate if requested.
    @throw Error upon no found module.
  ###
  @require = (context, module, surrogate) ->
    # Convert path to absolute
    path = Tweak.Common.relToAbs context, module
    try
      return Tweak.require path
    catch e
      return surrogate if surrogate?
      throw e
    return

  ###
    Split a name out to individual absolute names.
    Names formated like './cd[2-4]' will return an array or something like ['album1/cd2','album1/cd3','album1/cd4'].
    Names formated like './cd[2-4]a ./item[1]/model' will return an array or something
    like ['album1/cd2a','album1/cd3a','album1/cd4a','album1/item0/model','album1/item1/model'].
    @param [String] context The current context's name.
    @param [String, Array<String>] names The string to split into separate component names.
    @return [Array<String>] Array of absolute names.
  ###
  @splitMultiName = (context, names) ->
    # Reg-ex to split out the name prefix, suffix and the amount to expand by
    reg = ///
      ^           # Assert start of string
      (.*)        # Capture any character up to the next statement (prefix)
      \[          # Check for a single [ character
        (\d*)     # Greedily capture digits (min)
        (?:       # Look ahead
          [,\-]   # check for , or - character
          (\d*)   # Greedily capture digits (max)
        ){0,1}    # End look ahead - only between 0 and one times
      \]          # Check for a single ] character
      (.*)        # Capture any character up to the next statement (suffix)
      $           # Assert end of string
    ///

    # Split name if it is a string
    if typeof names is 'string'
      names = names.split /\s+/

    paths = []
    # Iterate through names in
    for name in names
      match = reg.exec name
      # If RegExp has a match then the name needs to be expanded
      if match?
        # Deconstruct match to variables
        [prefix, min, max, suffix] = match
        # For each name in min to max create a path name and push it to paths Array
        paths.push "#{prefix or ''}#{num}#{suffix or ''}" for num in [(min or 0)..(max or min)]
      else
        # Push name to paths Array
        paths.push name
    
    # Convert paths to absolute and return them
    Tweak.Common.relToAbs context, path for path in paths

  ###
    Convert a relative path to an absolute path; relative path defined by ./ or .\
    It will also navigate up per defined ../.
    @param [String] context The path to navigate to find absolute path based on given relative path.
    @param [String] relative The relative path to convert to absolute path.
    @return [String] Absolute path based upon the given context and relative path.


    @example Create absolute path from context of "albums/cds/songs"  with a path of '../cd1'
      Tweak.Common.toAbsolute('albums/cds/songs', '../cd1');
      // Returns 'albums/cds/cd1'

    @example Create absolute path from context of "album1/cd1"  with a path of './beautiful'
      Tweak.Common.toAbsolute('album1/cd1', './beautiful');
      // Returns 'album1/cd1/beautiful'
  ###
  @toAbsolute = (context, relative) ->
    # RegExp to find the affix point on the relative path (./ ../ ../../ ect)
    affixReg = ///
      ^           # Assert start of String
      (           # Open capture group
        \.+       # One or more . characters
        [\/\\]*   # Zero or more / characters
      )+          # Close capture group - capture 1 or more times
    ///
    
    # RegExp to detirmine how many levels path should go up by (defined by ../)
    upReg = ///
      ^         # Assert start of String
      \.{2,}    # Two or more . characters
      [\/\\]*   # Zero or more \ or / characters
    ///         
    
    # The amount or directories/paths to go up by
    amount = name.split(upReg).length-1 or 0

    # RegExp to reduce the context path
    reduceReg = ///
      (             # Open capture group
        [\/\\]*     # Zero or more \ or / characters
        [^\/\\]+    # One or more characters that are not \ or /
      ){#{amount}}  # Close capture group - capture x amount of times
      [\/\\]?       # Single \ or / charater - Lazy (doesn't have to exist)
      $             # Assert end of String
    ///

    # Return the combined paths
    name.replace affixReg, "#{context.replace reduceReg, 1}/"