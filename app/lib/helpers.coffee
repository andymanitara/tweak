###
----- HELPERS ----
Helper functions
###
  
###
  Description: Extend an objects prototype with functions. 
  Parameters: context:Object, selection:Array of (Strings or Functions), [properties:Array of Functions]
###
extend = tweak.Extend = (context, selection, properties) ->
  propertiesExist = if properties? then true else false
  proto = context::
  proto ?= context.__proto__
  for key, prop of selection
    if propertiesExist  
      proto[prop] ?= properties[prop]
    else 
      proto[key] = prop
  return
