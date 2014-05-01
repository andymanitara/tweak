###
  ----- Common -----
  Common functions that are used in multiple places throughout the framework
  The aim of this is to reduce the size of the framework

  Listed:
    init
###
tweak.Common =
  ###
    Description:  On initialisation of all of Tweak objects the init function is called. 
            It should be overriden by your code to interact with the object.  
  ###
  init: ->
   
  ###
    Parameters:   url:String, [params]
    Description:  If using require; this function will find the specified modules.
            This is used when building controllers and collections dynamically. 
            It will try to find specified modules; or default to tweaks default objects
  ###
  require: (url, params...) ->
    # Convert url to absolute path
    url = @relToAbs(url, @name)
    try 
      result = require url
    catch error 
      throw new Error "Can not find path #{url}"
    result


  relToAbs: (path, name) -> path.split("./").join("#{name}/")

  findModule: (paths, module, surrogate = null) ->
    for path in paths
      path = @relToAbs(path, @name)
      try         
        return require "#{path}/#{module}"
      catch e
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
    Parameters:   name:String, [params]
    Description:  Shortcut to event api trigger

    Example:    var app = new tweak.Controller({url:"data.json"});
            var name = "tweak";
            var name2 = "js";
            app.init = function() {
              this.trigger("eventname", name, name2); 
            };
  ###
  # Decided events should be staggered
  # Removing them from the scope of the script allows multiple benefits
  # Things will now proceed to run more effiecently during the triggering of events
  trigger: (params...) ->
    setTimeout(=>
      view = @view or @
      if typeof params[0] is "string"
        tweak.Events.trigger params...
      else view.DOMtrigger params...
    ,
    0)
    return

  on: (params...) ->
    view = @view or @
    if typeof params[0] is "string"         
        tweak.Events.on @, params...          
    else view.DOMon params...
    return

  off: (params...) ->
    view = @view or @
    if typeof params[0] is "string"
      tweak.Events.off @, params...
    else view.DOMoff params...
    return
  
  ###
    Parameters:   obj:(Object or Array)
    Description:  Clone an object to remove reference to original object or simply to copy it.
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
  ###   
  reduced: (arr, length) -> 
    start = arr.length - length
    for [start..length] then arr[_i]
  
 
  same: (one, two) ->
    for key, prop of one
      if not two[key]? or two[key] isnt prop then return false
    return true


  # Combine object properties into one
  combine: (mainObject, mergingObject) -> 
    for key, prop of mergingObject
      if typeof prop is 'object'
        mainObject[key] ?= if prop instanceof Array then [] else {}
        mainObject[key] = @combine(mainObject[key], prop)
      else
        mainObject[key] = prop
    mainObject

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