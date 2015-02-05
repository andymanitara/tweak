###
  A Controller defines the business logic between other modules. It can be used to
  control data flow, logic and more. It should process the data from the Model, 
  interactions and responses from the View, and control the logic between other 
  modules.
###
class tweak.Controller extends tweak.EventSystem
  # @property [Integer] The uid of this object - for unique reference
  uid: 0
  # @property [*] The root relationship to this module
  root: null
  # @property [*] The direct relationship to this module
  relation: null

  ###
    The constructor initialises the controllers unique ID, contextual relation and its root context. 

    @param [Context] relation The contextual object, usually it is the context of where this module is called.
  ###
  constructor: (relation) ->
    # Set uid
    @uid = "ct_#{tweak.uids.ct++}"
    # Set the relation to this object, if no relation then set it to a blank object. 
    @relation = relation ?= {}
    # Set the root relation to this object, this will look at its relations root.
    # If there is no root relation then this becomes the root relation to other modules. 
    @root = relation.root or @

  ###
    Default initialiser function
  ###
  init: ->