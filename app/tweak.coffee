###
  tweak.js 0.0.0

  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com
###

###
  All of the modules to the source code are seperated into the following files
  The order of the merging is detirmined in the brunch-config.coffee file 
 
  lib/common.coffee - commonly used functions throughout framework
  lib/helpers.coffee - helpers for the framework
  lib/events.coffee - TweakJS event system
###

###
  There isnt any requirements to TweakJS other than a JavaScript file and module loader.
  I recomend using RequireJS for the moment in time, because that is what i have been testing and working with. 
  A list of compatible module loaders will be added.
###

### Initialise tweak object to the window###
if typeof exports isnt 'undefined' then tweak = window.tweak = exports
else tweak = window.tweak = {}
