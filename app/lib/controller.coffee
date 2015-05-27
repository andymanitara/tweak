###
  A Controller defines the business logic between other modules. It can be used to
  control data flow, logic and more. It should process the data from the Model,
  interactions and responses from the View, and control the logic between other
  modules.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
###
class tweak.Controller extends tweak.Events
  ###
    By default, this does nothing during initialization unless it is overridden.
  ###
  init: ->