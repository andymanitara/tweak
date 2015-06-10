###
  A Controller defines the business logic between other modules. It can be used to
  control data flow, logic and more. It should process the data from the Model,
  interactions and responses from the View, and control the logic between other
  modules.

  The Controller is the 'Middle man'; eliminating logic from the views. This prevents
  complexity and further organizes your code. It is not a required module to use, however
  every component has one for you to use. 

  The benefits of the controller can include preprocessing of information and set-up of
  Components with its modules prior and after rendering a View. A Component upon its
  initialization will call the init method of its Controller module.
###
class Tweak.Controller extends Tweak.Events
  
  ###
    By default, this does nothing during initialization unless it is overridden.

    Note: You can apply logic to the constructor of the Controller, but you will not
    have any access to the other modules of the Component until the Component has been
    initialized.

    @example Providing set-up to a Component through the Controller.
      /*
        Register the Controller to the Component's path name with a Module loader,
        this will allow the Component to find its relating modules.
      */
      
      // Using a CommonJS set-up
      require.register('dummy/controller', function(exports, require, module) {
        var DummyComponentController;
        return module.exports = exports = DummyComponentController = (function() {
          function DummyComponentController() {}

          Tweak.extends(DummyComponentController, Tweak.Controller);

          DummyComponentController.prototype.init = function() {          
            // By passing true to to @model.set the model quietly updates            
            return this.model.set('topping', this.component.config.topping, true);
          };

          return DummyComponentController;

        })();
      });
      
  ###
  init: ->