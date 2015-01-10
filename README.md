## Introduction

Tweak.js is built to help developers build structured code; for use in web applications and web components whether small or big Tweak.js meets most needs. Tweak.js is a MVC based framework with some extra tools for creating applications with well structured code. 

Initially Tweak.js was structured for CoffeeScripters in mind, although it is very well adapted to CoffeeScript it also has functionality for support using pure JavaScript. Not only does Tweak.js behave nicely for the CoffeeScripters it can also be used with tools such as Brunch, Grunt and Gulp to create a powerful file/directory structure to keep all of your code organised.

In brief Tweak.js is a simple MVC framework with additions like components; used to dynamically create a set of models, view and controllers that are quickly reusable and extendable. Tweak.js also contains additional concepts such as Routers and Collections that can be used to create powerful web applications. Also included is a powerful Event API, the aim to make event delegation simple throughout your web applications and components. 

Tweak.js needs no dependencies on large frameworks such as JQuery. To attach html to the DOM you will need a template engine ([Handlebars](http://handlebarsjs.com/)). Tweak.js also contains an optional set of code for the view; this contains additional code that is useful for manipulating the DOM. However if you would live to do this with JQuery or a similar framework then that is also possible. 

For a full understanding to the framework please look at the [documentation](http://docs.tweakjs.com) or the source code.

## Use

To download the framework visit the [downloads page](http://dl.tweakjs.com).

Tweak.js is separated into three parts. This is to keep the core functionality separated to keep things light weight for simple use cases and for the extended functionality to be optionally added into your code.
* tweak.js (Models, View, Controller, Collection, Router, Event API, Classes)
* tweak.components.js (Component and Components)
* tweak.view.advanced.js (Additional view functionality)

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