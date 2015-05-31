###
  tweak.js 1.7.0

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###

wrapper = (root, tweak, require, $) ->
  pTweak = tweak
  tweak.$ = $
  tweak.require = require
  tweak.strict = false
  tweak.simple = true

  tweak.noConflict = ->
    root.tweak = pTweak
    @

  tweak

do (wrapper) ->  
  _root = (type) -> if typeof(type) is 'object' and type?.type is type then type else null
  root = _root(self) or _root global

  ### To keep alternative frameworks to jQuery available to tweak, 
      register/define the appropriate framework to '$'
  ###
  if typeof(define) is 'function' and define.amd
    define ['$', 'exports'], ($, exports) ->
      # I belive this snippet will enable a switch to a require based system with AMD
      toRequire = (module) -> define [module], (res) -> return res
      root.tweak = wrapper root, exports, toRequire , $
  else if typeof(exports) isnt 'undefined'
    try $ = root.require '$'
    if not $ then try $ = root.require 'jquery'
    wrapper root, exports, root.require, $
  else
    throw new Error 'It is required that tweakjs is used with module loaders'