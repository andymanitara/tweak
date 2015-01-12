## Introduction

Tweak.js is a MVC framework built to help developers structure code; for use in web applications and web components. Tweak.js is also accompanied with extra features that advances typical MVC concepts. 

Initially Tweak.js was primarily designed for CoffeeScripters, although JavaScripters can take advantage of some CoffeeScript features through the framework. Tweak.js becomes even more powerful with JavaScript task runners such as Brunch, Grunt and Gulp. With the use of task runners structuring code into appropriate files/directories is extremely simple and effective.

In addition to common MVC concepts Tweak.js introduces features like components. Components are used to dynamically create a set of linking modules like the typical Models, Views and Controllers; that can be configured, extended, reused and organised. Tweak.js also includes Collection and Router modules like that of typical frameworks. Furthermore, to enhance the relationship between modules Tweak.js includes a powerful event API. The event API is simple and designed to link actions between the individual modules in a async and synchronous manner.

Tweak.js is also built to be as independent as possible, removing needs for large frameworks such as jQuery. However use of these frameworks is still possible, they can be used just as you would normally. To keep Tweak.js extremely light it is separated into three fundamental parts. The separation includes a core set of modules, needed for MVC. A set of modules to enable component based features, and a set of modules that extends the view to increase the view functionality. The extra view functionality can be used when you want to keep filesize lighter with DOM manipulation.

For a full understanding to the framework please look at the [documentation](http://docs.tweakjs.com) or the source code.

## Use

### Downloads

This framework optionally depends on a **module loader** like [require.js](http://requirejs.org/). It can be used without a module loader however templates will need to be directly attached to a view.

To download the framework visit the [downloads page](http://dl.tweakjs.com).

* tweak.js (Models, View, Controller, Collection, Router, Event API, Classes)
 * The view module depends on a **template engine** like [handlebars.js](http://handlebarsjs.com/)
* tweak.components.js (Component and Components)
 * When using this set of modules Tweak.js depends on a **module loader** like [require.js](http://requirejs.org/)
* tweak.view.advanced.js (Additional view functionality)
 * This module extension depends a **selector engine** like [sizzle.js](http://sizzlejs.com/)

### Bower
Tweak.js is not yet hosted through bower - I aim to host it through bower when a strong stable version is available.

### Tags
```html
<!-- truncated -->
  <!-- Optional - module loader  -->
  <!-- Needed with tweak.components.js and if not directly attaching a template to a view  -->
  <script src="js/require.js"></script>
  <!-- Optional - module loader  -->

  <!-- Core -->
  <script src="js/handlebars-v1.3.0.js"></script>  <!-- For view module -->
  <script src="js/tweak.js"></script>
  <!-- Core -->
  
  <!-- Optional - Advanced View   -->
  <script src="js/sizzle.js"></script>
  <script src="js/tweak.view.advanced.js"></script>
  <!-- Optional - Advanced View  -->

  <!-- Optional - Components -->
  <script src="js/tweak.components.js"></script>
  <!-- Optional - Components  -->
</body>
<!-- truncated -->
```

### Templates/Skeletons
A skeleton for Grunt, Brunch a Gulp will shortly be created


## Concepts
### Model
A model is a module that stores simple temporary data for use in views and other modules. The model will call events when it's data is manipulated which can be levered to update other modules such as the view. The model's data can also communicate between a database, it will import and export data through JSON so it is completely database independent. For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Store'](http://docs.tweakjs.com/class/tweak/Store.html) and ['Model'](http://docs.tweakjs.com/class/tweak/Model.html) sections. 

### View
A view is a module used to render your interface for the user, it will take the data passed in from a model, to which you can use to build your 'view'. The view can be used with any templating library. The concept is to organize, listen and manipulate your interface. The view is independent to any stored data to keep your code well organised. For more information please look at the [documentation](http://docs.tweakjs.com) under the ['View'](http://docs.tweakjs.com/class/tweak/View.html) and ['ViewAdvanced'](http://docs.tweakjs.com/class/tweak/ViewAdvanced.html) sections.

### Controller
A controller is used as the main interface for controlling code between parts of your application. It is commonly used to control the data flow between your databases, models and views. The controller is therefore the logic controller between the modules in your application and components. For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Controller'](http://docs.tweakjs.com/class/tweak/Controller.html) section.

### Collections
A collection is similar to a model but instead it uses an Array as its structure instead of an Object. The collection can also be used to wrap a set of models or simple data. When storing simple data or models the collection can export and import data from a database; when using a collection of models the models will automatically be built based on the data being imported. For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Store'](http://docs.tweakjs.com/class/tweak/Store.html) and ['Collection'](http://docs.tweakjs.com/class/tweak/Collection.html) sections. 

### Router
Web applications often provide linkable, bookmarkable, shareable URLs for important locations in the app. The router module provides methods for routing to events which can control the application. For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Router'](http://docs.tweakjs.com/class/tweak/Router.html) section.

### Event API
Tweak.js is built in with an event API that can be used to bind/unbind and trigger events throughout modules and your application. This provides functionality to communicate simply and effectively while maintaining an organised structure to your code and applications. For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Events'](http://docs.tweakjs.com/class/tweak/Events.html) section.

### Components
Tweak.js components provide functionality to dynamically create extendable set of code. A component will build and tie together the core modules. To use this code you will need a module loader such as [require.js](http://requirejs.org/). For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Component'](http://docs.tweakjs.com/class/tweak/Component.html) and ['Component'](http://docs.tweakjs.com/class/tweak/Component.html) sections.

### Classes
Classes core to the framework it provides an solution to keep code organised, reusable and extendable. If using CoffeeScript you should be well adapted the class concept and its functionality. For more information and those using pure JavaScript please look at the [documentation](http://docs.tweakjs.com) under the ['Class'](http://docs.tweakjs.com/class/tweak/Class.html) section.