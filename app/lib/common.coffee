###
  This class contains common shared functionality. The aim to reduce repeated code
  and overall file size of the framework.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
###
class tweak.Common
  ###
    Merge properties from object from one object to another. (First object is the object to take on the properties from the second object).
    @param [Object, Array] one The Object/Array to combine properties into.
    @param [Object, Array] two The Object/Array that shall be combined into the first object.
    @return [Object, Array] Returns the resulting combined object from two Object/Array.
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
      if ref.hasOwnProperty(attr) then copy[attr] = @clone ref[attr]
    return copy

  ###
    Convert a simple JSON string/object.
    @param [JSONString, JSONObject] data JSONString/JSONObject to convert to vice versa.
    @return [JSONObject, JSONString] Returns JSON data of the opposite data type
  ###
  parse: (data) -> JSON[if typeof data is 'string' then 'parse' else 'data'] data

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
  findModule: (contexts, module, surrogate) ->
    # Iterate each context
    for context in contexts
      # Convert path to absolute
      try
        return tweak.Common.require context, module
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
  require: (context, module, surrogate) ->
    # Convert path to absolute
    path = tweak.Common.relToAbs context, module
    try
      return require path
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
  splitMultiName: (context, names) ->
    values = []
    # Reg-ex to split out the name prefix, suffix and the amount to expand by
    reg = /^(.*)\[(\d*)(?:[,\-](\d*)){0,1}\](.*)$/

    # Split name if it is a string
    if typeof names is 'string'
      names = names.split /\s+/

    # Iterate through names in
    for item in names
      result = reg.exec item
      # If Reg-ex matches then expand the name
      if result?
        prefix = result[1]
        min = result[2] or 0
        max = result[3] or min
        suffix = result[4]
        while min <= max
          values.push @relToAbs context, "#{prefix}#{min++}#{suffix}"
      else
        values.push @relToAbs context, item
    values

  ###
    Convert relative path to an absolute path; relative path defined by ./ or .\
    It will also reduce the prefix path by one level per ../ in the path.
    @param [String] context The context path.
    @param [String] name The path to convert to absolute path, based on the context path.
    @return [String] Absolute path.
  ###
  relToAbs: (context, name) ->
    amount = name.split(/\.{2,}[\/\\]*/).length-1 or 0
    context = context.replace new RegExp("([\\/\\\\]*[^\\/\\\\]+){#{amount}}[\\/\\\\]?$"), ''
    name.replace /^(\.+[\/\\]*)+/, "#{context}/"

  ###
    Apply event listener to a DOMElement, with cross/old browser support.
    @param [DOMElement] element A DOMElement.
    @param [String] type The type of event.
    @param [Function] callback The method to add to the events callbacks.
    @param [Boolean] capture (Default = false) After initiating capture, all events of
      the specified type will be dispatched to the registered listener before being
      dispatched to any EventTarget beneath it in the DOM tree. Events which are bubbling
      upward through the tree will not trigger a listener designated to use capture. If
      a listener was registered twice, one with capture and one without, each must be
      removed separately. Removal of a capturing listener does not affect a non-capturing
      version of the same listener, and vice versa.
  ###
  on: (element, type, callback, capture = false) ->
    element.__events ?= {}
    for key, event of element.__events[type] ?= [] when (not callback? or event.callback is callback) and event.capture is capture
      element.__events[type][key].enabled = true
      res = true
    if res then return
    element.__events[type].push {element, type, callback, capture, enabled: true}
    fn = (e) -> for event in element.__events[type] when event.enabled then event.callback e, event.element
    if window.addEventListener
      element.addEventListener type, fn, capture
    else if window.attachEvent
      element.attachEvent "on#{type}", fn
    else
      element["on#{type}"] = fn
    return

  ###
    Remove event listener to a DOMElement, with cross/old browser support.
    @param [DOMElement] element A DOMElement.
    @param [String] type The type of event.
    @param [Function] callback The method to remove from the events callbacks.
    @param [Boolean] capture (Default = false) Specifies whether the EventListener being
      removed was registered as a capturing listener or not. If a listener was registered
      twice, one with capture and one without, each must be removed separately. Removal of
      a capturing listener does not affect a non-capturing version of the same listener,
      and vice versa.
  ###
  off: (element, type, callback, capture = false) ->
    element.__events ?= {}
    for key, event of element.__events[type] ?= [] when (not callback? or event.callback is callback) and event.capture is capture
      element.__events[type][key].enabled = false
    return

  ###
    Trigger event listener on a DOMElement, with cross/old browser support.
    @param [DOMElement] element A DOMElement to trigger event on.
    @param [Event, String] event Event to trigger or string if to create new event.
  ###
  trigger: (element, event) ->
    doc = window.document
    if doc.createEvent
      if typeof event is 'string' then event = new Event event
      event.root = element
      element.dispatchEvent event
    else
      if typeof event is 'string' then event = doc.createEventObject()
      event.root = element
      element.fireEvent "on#{event}", event
    return
      
tweak.Common = new tweak.Common()