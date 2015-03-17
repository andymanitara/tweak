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

tweak.Super = (context, name) -> context.__super__[name].call @
  
###
  TweakJS was initially designed in CoffeeScript for CoffeeScripters. It is much
  easier to use the framework in CoffeeScript; however those using JS the
  following helpers will provide extending features that CoffeeScipt possess.
  These can also be used to reduce the file size of compiled CoffeeScript files.
###
class tweak.Class
  ###
    To extend an object with JS use tweak.Extends.
    @param [Object] child The child Object to extend.
    @param [Object] parent The parent Object to inheret methods.
    @return [Object] Extended object
  ###
  extends: (child, parent) ->

  ###
    To super a method with JS use this.super from within the class definition.
    To add super to prototype of a custom object not within the TweakJS classes
    in JS; do {class}.prototype.super = tweak.Super

    @param [Object] context The context to apply a super call to
    @param [string] name The method name to call super upon.
  ###
  super: (context, name) ->