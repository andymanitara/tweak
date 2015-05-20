###
  tweak.js 1.3.3

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
  
  tweak.view.html.js (optional)
    Adds core functionality for rendering templates to views in a web page.
    lib/view_html.coffee
###


### Initialise tweak object to the window ###
if typeof exports isnt 'undefined' then tweak = window.tweak = exports
else tweak = window.tweak = {}

###
  A count for the uid's
  Multiple sets of uid codes so its more manageable

  c = component
  cp = components
  v = view
  m = model
  r = router
  cl = collection
  ct = controller
  s = store
###
tweak.uids =
  c:0
  cp:0
  v:0
  m:0
  r:0
  cl:0
  ct:0
  s:0