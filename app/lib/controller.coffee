###
  A Controller defines the business logic between other modules. It can be used to
  control data flow, logic and more. It should process the data from the Model,
  interactions and responses from the View, and control the logic between other
  modules.
###
class tweak.Controller extends tweak.EventSystem
  # @property [Integer] The uid of this object - for unique reference
  uid: 0
  # @property [Method] see tweak.super
  super: tweak.super

  ###
    The constructor initialises the Controllers unique ID.
  ###
  constructor: -> @uid = "ct_#{tweak.uids.ct++}"

  ###
    By default, this does nothing during initialization unless it is overridden.
  ###
  init: ->