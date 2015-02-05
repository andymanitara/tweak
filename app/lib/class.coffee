tweak.__hasProp = {}.hasOwnProperty

tweak.Extends = (child, parent) ->
  ctor = ->
    @constructor = child
    return
  for key of parent
    child[key] = parent[key] if tweak.__hasProp.call parent, key
  ctor:: = parent::
  child:: = new ctor()
  child.__super__ = parent::
  child

tweak.Super = (child, name) -> 
  child.__super__[name].call @
  return

###
  TweakJS was intitially designed in CoffeeScript for CoffeeScripters.
  It is much easier to use the framework in coffeescript; however those using JS the following helpers will provide extending features that coffeescipt possess
  These can also be used to reduce the file size of compiled coffeescript files.
###
class tweak.Class
  ###
    This is a dummy method - for documentation purposes only.
    To extend an object with JS use tweak.Extends
  ###
  extends: (child, parent) ->

  ###
    This is a dummy method - for documentation purposes only.
    To super a method with JS use this.super. 
    To add super to prototype of a custom object not within the TweakJS classes in JS; do {class}.prototype.super = tweak.Super
  ###
  super: (child, name) ->