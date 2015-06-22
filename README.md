# Tweak.js - Component driven MVC framework.

[![Join the chat at https://gitter.im/tweak-js/tweak](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/tweak-js/tweak?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![npm version](https://badge.fury.io/js/tweakjs.svg)](http://badge.fury.io/js/tweakjs)
[![Bower version](https://badge.fury.io/bo/tweakjs.svg)](http://badge.fury.io/bo/tweakjs)
[![Dependency Status](https://david-dm.org/tweak-js/tweak.svg)](https://david-dm.org/tweak-js/tweak)
[![devDependency Status](https://david-dm.org/tweak-js/tweak/dev-status.svg)](https://david-dm.org/tweak-js/tweak#info=devDependencies)

master: [![Build Status](https://travis-ci.org/tweak-js/tweak.svg?branch=master)](https://travis-ci.org/tweak-js/tweak)
develop: [![Build Status](https://travis-ci.org/tweak-js/tweak.svg?branch=develop)](https://travis-ci.org/tweak-js/tweak)

## Introduction
Tweak.js is a MVC framework built to help developers' structure code; for use in web applications and web Components. Tweak.js is also accompanied with extra features that advances typical MVC concepts. JavaScripters can take advantage of class features through Tweak.js, this makes OOP JavaScript easy to use even for JavaScipt purists. Tweak.js becomes even more powerful with JavaScript task runners such as Brunch, Grunt and Gulp. With the use of task runners structuring code into appropriate files/directories is extremely simple and effective.

In addition to common MVC concepts Tweak.js introduces features like Components. Components are used to dynamically create a set of linking modules like the typical Models, Views and Controllers; that can be configured, extended, reused and organised. Tweak.js also includes Collection and Router modules like that of typical frameworks. Furthermore, to enhance the relationship between modules Tweak.js includes a powerful event system. The event system is simple and designed to extend modules/classes/objects with functionality to link actions between the individual modules.

For a full understanding to the framework please look at the [documentation](http://docs.tweakjs.com) or the source code.

## Use
### Installation
BOWER: `bower install tweakjs`

NPM: `npm install tweakjs`

### Dependencies
* Depends on a **CommonJS based loader** see [description on module loaders](http://addyosmani.com/writing-modular-js/)
* Depends on a **DOM engine** like [jquery](http://jquery.com/) or [zepto](http://zeptojs.com/)
* An optional dependency of a **template engine** like [handlebars.js](http://handlebarsjs.com/) can be used.

### Tags
[[CommonJS loader]](http://addyosmani.com/writing-modular-js/) - List of module/script loaders.

[[template engine]](http://garann.github.io/template-chooser/) - list of template engines.

[[template engine]](http://garann.github.io/template-chooser/) - list of template engines.

```html
<!-- truncated -->
  <script src="js/[CommonJS loader].js"></script>
  <script src="js/[template engine].js"></script>
  <script src="js/[DOM engine].js"></script>
  <script src="js/tweak.js"></script>
</body>
<!-- truncated -->
```

### Templates/Skeletons
A skeleton for Grunt, Brunch a Gulp will shortly be created

### Extensions/Plugins
As Tweak.js is built with CoffeeScript; which utilises OOP Classes, extending the framework is as easy as eating some pie. For example applying different template engines can be applied by an extension/plugin. 

When creating an extension/plugin to a framework, please use the naming convention of [Name]Tweaked, example JadeTweaked. This will make it easy for people to find extensions/plugins to the framework. This isn't a required naming convention, just a preference, so don't worry if the name is already taken.

For a list of extensions/plugins look at EXTENSIONS.md. Please fork and add to the EXTENSIONS.md if you wish to submit an extension. An example extension will be supplied, along with how to apply it to the Framework.

## Concepts
Below is a rough guide to the concepts used within Tweak.js. Additional information can be found on the web to help your understanding on MVC concepts. For more in-depth details on what Tweak.js can do, look at the relevant module in the [documentation](http://docs.tweakjs.com/) or look at the source code for line by line comments. Better yet just get stuck in and mess around with it; its versatile for lots of needs.  

### Model
A Model is used by other modules like the Controller to store, retrieve and listen to a set of data. A Model triggers events when it's storage base is updated, this makes it easy to listen to changes and to action as and when required. The Model’s data is not a database, but a JSON representation of its data can be exported and imported to and from storage sources. In Tweak.js the Model extends the ['Store'](http://docs.tweakjs.com/class/tweak/Store.html) module - which is the core functionality shared between Model's and Collection's. The main difference between a Model and collection it the base of its data type. The Model uses an object as its base data type and a collection base type is an Array.

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Store'](http://docs.tweakjs.com/class/tweak/Store.html) and ['Model'](http://docs.tweakjs.com/class/tweak/Model.html) sections.

### View
A View is a module used as a presentation layer. Which is used to render, manipulate and listen to an interface. The Model, View and Controller separates logic of the Views interaction to that of data and functionality. This helps to keep code organized and tangle free - the View should primarily be used to render, manipulate and listen to the presentation layer. A View consists of a template to which data is bound to and rendered/re-rendered. 

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['View'](http://docs.tweakjs.com/class/tweak/View.html).

### Controller
A Controller defines the business logic between other modules. It can be used to control data flow, logic and more. It should process the data from the Model, interactions and responses from the View, and control the logic between other modules.

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Controller'](http://docs.tweakjs.com/class/tweak/Controller.html) section.

### Collection
A Collection is used by other modules like the Controller to store, retrieve and listen to a set of ordered data. A Collection triggers events when it's storage base is updated, this makes it easy to listen to changes and to action as and when required. The Collection data is not a database, but a JSON representation of its data can be exported and imported to and from storage sources. In Tweak.js the Model extends the ['Store'](http://docs.tweakjs.com/class/tweak/Store.html) module - which is the core functionality shared between Model's and Collection's. The main difference between a Model and collection it the base of its data type. The Model uses an object as its base data type and a collection base type is an Array.

To further extend a Collection, Tweak.js allows data to be imported and exported. When doing this please know that all data stored should be able to be converted to a JSON string. A Collection of Models can also be exported and imported to and from a database, as it has an inbuilt detection for when a value should be created as a Model representation. Keep note that a Collection of Collections is not appropriate as this becomes complicated and it can get messy quickly. It should be possible to export and import data of that nature, but it’s not recommended - always try to keep stored data structured simply.

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Store'](http://docs.tweakjs.com/class/tweak/Store.html) and ['Collection'](http://docs.tweakjs.com/class/tweak/Collection.html) sections.

### Router
The Router which hooks into the tweak.History change events which provides information back from the URL. The Router module provides routing to events which can control the application and its modules.

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Router'](http://docs.tweakjs.com/class/tweak/Router.html) section.

### History
The History is a cross-browser friendly version of the HTML5 history API. When available it uses the HTML5 pushState else it provides a backwards compatible solution to having a stored history, either hashState or an interval that checks at a set rate. The history provides routes to your application/component which updates the application/components based on the URL information. The current URL location can also be set to provide a Shareable/linkable/bookmark-able URL to specific places in your application. 

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['History'](http://docs.tweakjs.com/class/tweak/History.html) section.

### Event System
Tweak.js has an event system class, this provides functionality to extending classes to communicate simply and effectively while maintaining an organised structure to your code and applications. Each object can extend the tweak.EventSystem class to provide event functionality. Majority of Tweak.js modules/classes already extend the EventSystem class, however when creating custom objects/classes you can extend the class using the tweak.Extends method, please see ['Class'](http://docs.tweakjs.com/class/tweak/Class.html) class in the [documentation](http://docs.tweakjs.com).

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Events'](http://docs.tweakjs.com/class/tweak/Events.html) class.

### Components
Components are used to dynamically create a set of linking modules like the typical Models, Views and Controllers; that can be configured, extended, reused and organised. A Component will build and tie together modules.

Components will automatically detect inherited modules through a depended upon module loader such as [require.js](http://requirejs.org/). This increases versatility of Tweak.js, by creating an eco-system of reusable, configurable and organised Components. This is a unique twist to common MVC frameworks as it provides a wrapper that helps make understanding the links between the concepts of MVC clearer. It is also brilliant for saving development time.

Components bring Object Oriented Programming (OOP) concepts into MVC and JavaScript. Which acts as a powerful structuring mechanism to web applications. They are also configurable through a configuration object, the configuration object cleverly inheriting its extended components configuration as its base configuration object.

For more information please look at the [documentation](http://docs.tweakjs.com) under the ['Component'](http://docs.tweakjs.com/class/tweak/Component.html) and ['Component'](http://docs.tweakjs.com/class/tweak/Component.html) sections.

### Classes
Classes are core to Tweak.js as it provides a solution to keep code organised, reusable and extend-able. If using CoffeeScript you should be well adapted the OOP concepts and its functionalities. JavaScript purists can take advantage of Tweak.js' built in methods to embed OOP concepts; please look at the documentation/source for more information - [documentation](http://docs.tweakjs.com).

### Templates
A template, written in a template language, describes the user interface of your application. Tweak.js doesn't limit you to how you create your templates, however as a rough guide; a template normally will be generated from a template engine like handlebars. Template engines will typically tie to a object to use as its construction, in Tweak.js this is normally your object. Templates are generated through the View module upon a render process, for more information on how this works look at the View modules documentation.

Currently Tweak.js uses HandleBars as it core template engine. You can override how templates are generated by extending the View module. This may be restructured in the future to not have any defaults; with handlebars and other generation methods being provided through extensions. 

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


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/tweak-js/tweak/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

