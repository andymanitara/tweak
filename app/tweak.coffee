###
  tweak.js 1.7.2

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com

  Brunch-config wrappes this coffeescript file and its modules into self contained function.
###
wrapper = (root, tweak, require, $) ->
  pTweak = tweak

  ###
   Assign $ to tweak for internal use and allow to be overridden at anypoint
  ###
  tweak.$ = $

  ###
   Assign the module loader's require method to tweak.require. By default it
   used the passed require. However, for example, if using Curl then curl can
   be assigned to tweak.require
  ###
  tweak.require = require

  ###
    By default when creating a new Component if there is not an initial
    external config file relating to that Component then it doesn't matter.
    However when extending lots of Components it is generally better to
    make external relating config objects required to be found by a module loader
    so mistakes are reduced. 
  ###
  tweak.strict = false

  ###
    Restore the previous stored tweak.
  ###
  tweak.noConflict = ->
    root.tweak = pTweak
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
      This may need adjustment to 
    ###
    toRequire = (module) -> define [module], (res) -> return res
    wrapper root, root.tweak = exports, toRequire , $
else if typeof(exports) isnt 'undefined'
  ###
    CommonJS and Node environment
  ###
  try $ = require '$'
  if not $ then try $ = require 'jquery'
  wrapper root, exports = root.tweak = {}, require, $
else
  ###
    Typical web environment - even though a module loader is required
    it is best to allow the user to set it up. Example Brunch uses CommonJS
    however it does not work exactly like it does in node so it goes through here
  ###
  wrapper root, root.tweak = {}, require, root.jQuery or root.Zepto or root.ender or root.$

###
  Due to a slight annoyance with coffeescript self wrapping to make it work in node
  we need to assign to module[ClassName] = class ClassName 
  However this will break in a web enviroment as exports isnt defined. So we create
  a dummy exports variable within this code
###
if typeof(exports) is 'undefined' then exports = root.tweak 