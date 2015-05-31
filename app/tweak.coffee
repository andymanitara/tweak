###
  tweak.js 1.7.0

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###

###
  All of the modules to the source code are separated into the following files
  The order of the merging is determined in the brunch-config.coffee file
 
  tweak.js
    This is the core of the framework - with these modules you can use them in any many of way.
    lib/common.coffee - Common methods used throughout the framework
    lib/class.coffee - Methods to supply JS users the ability to use CoffeScripts OOP methology.
    lib/events.coffee - Event system
    lib/store.coffee - Core/shared code for collections and models
    lib/collection.coffee
    lib/controller.coffee
    lib/model.coffee
    lib/view.coffee
    lib/component.coffee
    lib/components.coffee - collection of components
    lib/router.coffee
    lib/history.coffee
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