###
  tweak.js 1.7.10

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###
###
  Tweak.js can be accessed globaly by tweak or Tweak. If using in node or a
  CommonJs then Tweak.js is not global.

  @note Assign ($, jQuery, Zepto...) to Tweak.$ for internal use. By default it
  will try to auto detect a value to use. This value can be overriden at any point.
  
  @note Assign module loader's require method to Tweak.require. By default it
  will try to auto detect a value to use; depending on the enviroment and module
  loader used you may need to overwrite this value.
  
  @note Assign true to Tweak.strict when you wish all components to require a related
  config module. By default this module does not need to exist however it is recommended
  as it allows powerful auto generation of components and deep extensions.

  Examples are not exact, and will not directly represent valid code; the aim of
  an example is to be a rough guide. JS is chosen as the default language to
  represent Tweak.js as those using 'compile-to-languages' should have a good
  understanding of JS and be able to translate the examples to a chosen language.
  Support can be found through the community if needed. Please see our
  Gitter community for more help {http://gitter.im/blake-newman/TweakJS}.
###
class Tweak
  ###
    This constructs Tweak with default properties. Tweak is automatically assigned to
    Tweak, tweak and module.exports.
  ###
  constructor: (@root, tweak, @require, @$) ->
    @prevTweak = @root.tweak or tweak

  ###
    To extend an object with JS use Tweak.extends.
    @note This is documented as a variable but is actually a method
    @param [Object] child The child Object to extend.
    @param [Object] parent The parent Object to inheret methods.
  ###
  extends: `extend`

  ###
    Bind a context to a method. For example with 'that' being a
    different context tweak.bind(this.pullyMethod, that).
    @note This is documented as a variable but is actually a method
    @param [Function] fn The function to bind a property to.
    @param [Context] context The context to bing to a function.
  ###
  bind: `bind`

  ###
    To super a method with JS use Tweak.super(context);.
    Alternativaly just do (example) Model.__super__.set(this)
    @param [Object] context The context to apply a super call to
    @param [string] name The method name to call super upon.
    @param [Obect] that Pass a context to the super call
  ###
  super: (context, name, that) -> context.__super__[name].call that

  ###
    Restore the previous stored Tweak/tweak.
  ###
  noConflict: ->
    if pTweak then tweak = Tweak = @pTweak
    @

  ###
    Clone a simple Object to remove reference to original Object or simply to copy it.
    @param [Object, Array] ref Reference Object to clone.
    @return [Object, Array] Returns the copied Object, while removing references.
    @throw An error will be thrown if an object type is not supported.

    @example Cloning an Object
      var obj, obj2;
      obj = {
        test:'test',
        total:4
      }
      
      // Clone the object
      obj2 = tweak.Clone(obj);
      
      // Alter the new object without adjusting other Object
      obj2.test = null

  ###
  clone: (obj, parent) ->
    # Returns itself if doesnt exist or if the obj is the same as the parent.
    # This prevents stackoverflow if objects include themselves (like window).
    if not obj? or typeof obj isnt 'object' or obj is parent
      return obj

    # Clone Date object
    if obj instanceof Date
      return new Date obj.getTime()

    # Clone RegExp Object
    if obj instanceof RegExp
      # Recreate RegExp flags
      flags = ''
      flags += 'g' if obj.global?
      flags += 'i' if obj.ignoreCase?
      flags += 'm' if obj.multiline?
      flags += 'y' if obj.sticky?
      return new RegExp obj.source, flags

    # Recreate new Object or Array
    _new = if obj instanceof Array then [] else {}

    for key of obj when obj.hasOwnProperty key
      _new[key] = @clone obj[key], obj

    return _new

  ###
    Switch a JSONObject/JSONString to it alternative type.
    @param [JSONString, JSONObject] data JSONString/JSONObject to convert to vice versa.
    @return [JSONObject, JSONString] Returns JSONString/JSONObject data of the alternative type of passed value

    @example JSON conversions
      var jString, jObj;

      jString = '{"cats":"meow"}';
      jObj = {
        dogs:'woof'
      }

      tweak.JSON(jString);
      // Returns Object - { "cats":"meow" }

      tweak.JSON(jObj);
      // Returns String - "{"dogs":"woof"}"
  ###
  JSON: (data) -> JSON[if typeof data is 'string' then 'parse' else 'stringify'] data

  ###
    Try to find a module by name from multiple paths returning the first found module.
    A final surrogate will be returned if no modules could be found.
    @param [Array<String>] paths An array of context paths.
    @param [String] module The module path to convert to absolute path; based on the context path.
    @param [Object] surrogate (Optional) A surrogate Object that can be used if there is no module found.
    @return [Object] Returns an Object that has the highest priority.
    @throw When a module is not found and there is no surrogate an error will be thrown -
      "No module #{module name} for #{component name}".
    @throw An error will be thrown if an object is found but an error occured during processing

    @example Request 'template' module from contexts of ['app/index', 'components/page']
      Tweak.request(['app/index', 'components/page'], './template');
      // Returns template module if found in any of the contexts or throws error

    @example Request 'template' module from contexts of ['app/index', 'components/page'], if not found a surrogate is used
      var sur;
      sur = {
        body:'<body></body>'
      }
      Tweak.request(['app/index', 'components/page'], './template', surr);
      // Returns template module if found or returns the surrogate
  ###
  findModule: (contexts, module, surrogate) ->
    # Iterate each context
    for context in contexts
      try
        # Attempt to request module
        return @request context, module
      catch e
        # If the error thrown isn't a direct call on 'Error' Then the module was found
        # however there was an internal error in the module
        if e.name isnt 'Error'
          throw e
    # No module found - return sourrogate if supplied
    return surrogate if surrogate?
    # Throw an error as no module is found
    throw new Error "No module #{module} for #{contexts[0]}"

  ###
    Require/request a module from given context and path or return a surrogate
    @param [String] context The context path.
    @param [String] module The module path to convert to absolute path, based on the context path.
    @param [Object] surrogate (Optional) A surrogate Object that can be used if there is no module found.
    @return [Object] Required/requested module or the surrogate if requested.
    @throw Error upon no found module.

    @example Request 'template' module from 'app/index'
      Tweak.request('app/index', './template');
      // Returns template module if found or throws error

    @example Request 'template' module from 'app/index', if not found a surrogate is used
      var sur;
      sur = {
        body:'<body></body>'
      }
      Tweak.request('app/index', './template', sur);
      // Returns template module if found or returns the surrogate

  ###
  request: (context, module, surrogate) ->
    # module path to absolute
    path = @toAbsolute context, module
    try
      # Try to require the module returning if successful
      return @require path
    catch e
      # If there is in error then attempt to use a surrogate
      # If returns surrogate else it throws the error
      return surrogate if surrogate?
      throw e
    # Void return
    return

  ###
    Split a path formated as a 'multi-path' into individual paths.
    @param [Array<String>, String] paths 'multi-path's to format.
    @return [Array<String>] Array of paths.

    @example Names formated as './cd[2-4]'
      Tweak.splitPaths('./cd[2-4]');
      // Returns ['./cd2','./cd3','./cd4']

    @example Names formated as ['./cd[2]/model', '../what1']
      Tweak.splitPaths(['./cd[2]', '../what1']);
      // Returns ['./item0/model','./item1/model','./item2/model', '../what1']

    @example Names formated as single space delimited String './cd[2]/model ../what1'
      Tweak.splitPaths('./cd[2]/model ../what1');
      // Returns ['./item0/model','./item1/model','./item2/model', '../what1']
  ###
  splitPaths: (paths) ->
    # RegExp to split out the name prefix, suffix and the amount to expand by
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
    if typeof paths is 'string'
      paths = paths.split /\s+/

    results = []
    # Iterate through paths
    for path in paths
      match = reg.exec path
      # If RegExp has a match then the path needs to be expanded
      if match?
        # Deconstruct match to variables
        [prefix, min, max, suffix] = match
        # For each path in min to max create a single path and push it to results Array
        results.push "#{prefix}#{num}#{suffix}" for num in [(min or 0)..(max or min)]
      else
        # Push path to results Array
        results.push path
    # Return split paths
    results

  ###
    Convert a relative path to an absolute path; relative path defined by ./ or .\
    It will also navigate up per defined ../.
    @param [String] context The path to navigate to find absolute path based on given relative path.
    @param [String] relative The relative path to convert to absolute path.
    @return [String] Absolute path based upon the given context and relative path.


    @example Create absolute path from context of "albums/cds/songs"  with a path of '../cd1'
      Tweak.toAbsolute('albums/cds/songs', '../cd1');
      // Returns 'albums/cds/cd1'

    @example Create absolute path from context of "album1/cd1"  with a path of './beautiful'
      Tweak.toAbsolute('album1/cd1', './beautiful');
      // Returns 'album1/cd1/beautiful'
  ###
  toAbsolute: (context, relative) ->
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
    amount = relative.split(upReg).length-1 or 0

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
    relative.replace affixReg, "#{context.replace reduceReg, ''}/"
  
###
  Assign root as either self, global or window.
###
root = (typeof(self) is 'object' and self.self is self and self) or
(typeof(global) is 'object' and global.global is global and global) or
window

###
  To keep alternative frameworks to jQuery available to tweak,
  register/define the appropriate framework to '$'
###
if typeof(define) is 'function' and define.amd
  define ['$', 'exports'], ($, exports) ->
    ###
      This will enable a switch to a CommonJS based system with AMD.
    ###
    toRequire = (module) -> define [module], (res) -> return res
    exports = Tweak = root.tweak = root.Tweak = new Tweak root, exports, toRequire , $
else if typeof(exports) isnt 'undefined'
  ###
    CommonJS and Node environment
  ###
  try $ = require '$'
  if not $ then try $ = require 'jquery'
  module?.exports = tweak = Tweak = new Tweak root, exports, require, $
else
  ###
    Typical web environment - even though a module loader is required
    it is best to allow the user to set it up. Example Brunch uses CommonJS
    however it does not work exactly like it does in node so it goes through here
  ###
  Tweak = root.tweak = root.Tweak = new Tweak root, {}, root.require, root.jQuery or root.Zepto or root.ender or root.$
