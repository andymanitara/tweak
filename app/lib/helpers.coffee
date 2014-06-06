###
  Extend an objects prototype with functions.
  @overload tweak.Extend(context, selection, properties)
    Extend an objects prototype with functions from another object, based on an array of names
    @param [Object] context context to apply the methods
    @param [Array<String>] selection An array of strings representing the names of function to apply to the context
    @param [Object] properties an object containing the functions to extend to the context

  @overload tweak.Extend(context, functions)
    Extend an objects prototype with functions
    @param [Object] context context to apply the methods
    @param [Array<Function>, Object<Functions>] functions to apply to an object
###
tweak.Extend = (context, selection, properties) ->
  propertiesExist = if properties? then true else false
  proto = context::
  proto ?= context.__proto__
  for key, prop of selection
    if propertiesExist
      proto[prop] ?= properties[prop]
    else
      proto[key] = prop
  return