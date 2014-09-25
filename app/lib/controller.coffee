###
  The controller should be used to control the logic and functionality between components modules.
  The controller allows for seperation for your logic. You can still use the view and the model ect to control logic, but think of this as your middle man/ blank canvas.
  By seperating the logic between the model and view you allow for much cleaner code. The view can still contain logic; but try keep this logic based on the interface between the user and view.

  The view could be used to define the parts of interaction; and animating things.
  The model can be used for validating data on updateing of data allowing a simple continuous checking system seperate from your logic.
  Therefore the complex logic between what happens on certain interaction can remain in the controller; making it simpler to understand what happens where and when.
  It now keeps your code clean from long and extensive validation and animation logic; which can make code hard to understand when trying to debug why something wont happen after another thing.

  The controller inherits a few mixins to allow for more controll in the framework; but in general it is very minimal.

  @todo reduce the amount of mixins. This will be easier once i know the commonly used functionality. Probably will end up being require, findModule, trigger, on, off, init, construct.

  @include tweak.Common.Empty
  @include tweak.Common.Events
  @include tweak.Common.Collections
  @include tweak.Common.Arrays
  @include tweak.Common.Modules
  @include tweak.Common.Components
###
class tweak.Controller

  # @property [Interger] The uid of this object - for unique reference
  uid: 0
  # @property [Integer] The component uid of this object - for unique reference of component
  cuid: 0
  # @property [Component] The root component
  root: null

  
  tweak.Extend @, [
    tweak.Common.Empty,
    tweak.Common.Events,
    tweak.Common.Modules,
    tweak.Common.Collections,
    tweak.Common.Arrays,
    tweak.Common.Modules,
    tweak.Common.Components
  ]

  # @private
  constructor: ->
    # Set uid
    @uid = "ct_#{tweak.uids.ct++}"