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
A model is a module that is used by other modules like the Controller to store, retrieve and listen to a set of data. Tweak.js will call events through its **event system** when it is updated, this makes it easy to listen to updates and to action as and when required. The model’s data is not a database, but a JSON representation of its data can be exported and imported to and from storage sources. In Tweak.js the model extends the ['Store'](http://docs.tweakjs.com/class/tweak/Store.html) module - which is the core functionality shared between the Model and Collection. The main difference between a model and collection it the base of its storage. The Model uses an object to store its data and a collection base storage is an Array. 

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Store'](http://docs.tweakjs.com/class/tweak/Store.html) and ['Model'](http://docs.tweakjs.com/class/tweak/Model.html) sections.

### View
A view is a module used and a presentation layer. Which is used to render, manipulate and listen to an interface. The model, view and controller separates logic of the views interaction to that of data and functionality. This helps to keep code organized and tangle free.  The view should be used to manipulate and listen to the presentation layer. A view consists of a template to which data is binded to and rendered/re-rendered. 

Tweak.js has two parts to the view. Its core being available in the main file of Tweak.js provides simple rendering logic. However to further manipulate the DOM and its rendered template, the view can be extended with additional functionality. The extra functionality is for manipulating the DOM, it is a very light weight alternative to jQuery for when creating a lightweight application is priority.  

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['View'](http://docs.tweakjs.com/class/tweak/View.html) and ['ViewAdvanced'](http://docs.tweakjs.com/class/tweak/ViewAdvanced.html) sections.

**Note**
The view may be further stripped back to allow for multiple presentation layers. With the core view being fully extendable to cope for CLI, HTML and more. This will make tweak.js much more versatile. If any one would like to help with this feature - please contact me.

### Controller
A controller defines the business logic between other modules. It can be used to control data flow, logic and more. It should process the data from the model, interactions and responses from the view, and control the logic between other modules. The controller has access to the Event api and thus it can use this functionality to keep control of events that happen throughout your application, components and modules . 

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Controller'](http://docs.tweakjs.com/class/tweak/Controller.html) section.

### Collections
A collection is a module that is used by other modules like the Controller to store, retrieve and listen to a set of ordered data. Tweak.js will call events through its **event system** when the collection is updated, this makes it easy to listen to updates and to action as and when required. The collection data is not a database, but a JSON representation of its data can be exported and imported to and from storage sources. In Tweak.js the collection extends the ['Store'](http://docs.tweakjs.com/class/tweak/Store.html) module - which is the core functionality shared between the Model and Collection. The main difference between a collection and model it the base of its storage. The Model uses an object to store its data and a collection base storage is an Array. 

To further extend a collection, Tweak.js allows data to be imported and exported. When doing this please bare in mind that all data stored should be able to be converted to a JSON string. A collection of models can also be exported and imported to and from a database, as it has an inbuilt detection for when a value should be created as a model representation. Keep note that collections of collections is not appropriate as this becomes a complicated and it can get messy quickly, it should be possible to export and import data of that nature but have fun. Always try to keep stored data structured simply.

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Store'](http://docs.tweakjs.com/class/tweak/Store.html) and ['Collection'](http://docs.tweakjs.com/class/tweak/Collection.html) sections.

### Router
Web applications often provide linkable, bookmarkable, shareable URLs for important locations in the app. The router module provides methods for routing to events which can control the application. 

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Router'](http://docs.tweakjs.com/class/tweak/Router.html) section.

### Event System
Tweak.js is built in with an event system that can be used to bind/unbind and trigger events throughout modules and your application. This provides functionality to communicate simply and effectively while maintaining an organised structure to your code and applications. 

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Events'](http://docs.tweakjs.com/class/tweak/Events.html) section.

### Components
Components are used to dynamically create a set of linking modules like the typical Models, Views and Controllers; that can be configured, extended, reused and organised.  A component will build and tie together modules. 

Components will automatically detect inherited modules through a depended module loader such as [require.js](http://requirejs.org/). This increases versatility of Tweak.js, by create an eco system of reusable, configurable and organised components. This is a unique twist to common MVC frameworks as it provides a wrapper that helps make understanding the links between the concepts of MVC clear. It is also brilliant for saving development time. 

Components bring Object Oriented Programing (OOP) concepts into MVC and Javascript. Which acts as a powerful structuring mechanism to web applications. They are also configurable through a config object, the config object cleverly inheriting its extended components config as its base config object.

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Component'](http://docs.tweakjs.com/class/tweak/Component.html) and ['Component'](http://docs.tweakjs.com/class/tweak/Component.html) sections.

### Classes
Classes are core to Tweak.js as it provides a solution to keep code organised, reusable and extendable. If using CoffeeScript you should be well adapted the class concept and its functionality. The Class module provides JavaScript purists a way to use CoffeeScript based functionality to make objects extendable without the complicated code that comes with it. Supering inherited classes is also available through the class module.

For more information and those using pure JavaScript please look at the [documentation](http://docs.tweakjs.com) under the ['Class'](http://docs.tweakjs.com/class/tweak/Class.html) section.

### Templates
A template, written in a templating language, describes the user interface of your application. Each template is backed by a model, each template can be updated when you choose.

## Contribution
Feel free to contribute in any way you can. Whether it is contributing to the source code or [donating](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=648D6YUPB88XG) to help development. Tweak.js will always remain open source and I will never ask for your personal details.

## License

The MIT License (MIT)

Copyright (c) 2014 Blake Newman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE