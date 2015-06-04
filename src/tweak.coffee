###
  tweak.js 1.7.7

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###
###
  Tweak.js can be accessed globaly by tweak or Tweak. If using in node or a 
  CommonJs then Tweak.js is not global.
###
class Tweak
  ###
    Assign $ to tweak for internal use and allow to be overridden at anypoint
  ###
  $:undefined

  ###
   Assign the module loader's require method to tweak.require. By default it
   used the passed require. However, for example, if using Curl then curl can
   be assigned to tweak.require
  ###
  require:undefined

  ###
    By default when creating a new Component if there is not an initial
    external config file relating to that Component then it doesn't matter.
    However when extending lots of Components it is generally better to
    make external relating config objects required to be found by a module loader
    so mistakes are reduced.
  ###
  strict:false

  constructor: (@root, tweak, @require, @$) ->
    @prevTweak = @root.tweak or tweak

  ###
    To extend an object with JS use tweak.extends.
    @param [Object] child The child Object to extend.
    @param [Object] parent The parent Object to inheret methods.
  ###
  extends: `extend`

  ###
    Bind a context to a method. For example with 'that' being a
    different context tweak.bind(this.pullyMethod, that);.
    @param [Function] fn The function to bind a property to.
    @param [Context] context The context to bing to a function.
  ###
  bind: `bind`

  ###
    To super a method with JS use tweak.super(context);.
    Alternativaly just do (example) Model.__super__.set(this)
    @param [Object] context The context to apply a super call to
    @param [string] name The method name to call super upon.
    @param [Obect] that Pass a context to the super call
  ###
  super: (context, name, that) -> context.__super__[name].call that

  ###
    Restore the previous stored tweak.
  ###
  noConflict: ->
    if pTweak then tweak = Tweak = @pTweak
    @
  

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
    exports = root.tweak = root.Tweak = new Tweak root, exports, toRequire , $
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
  root.tweak = root.Tweak = new Tweak root, {}, root.require, root.jQuery or root.Zepto or root.ender or root.$
