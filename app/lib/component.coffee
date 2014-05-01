### 
  ----- COMPONENT -----
  TweakJS has its own unique twist to the MVC concept. 

  The future of MVC doesnt always lie in web apps; the architecture to TweakJS allows for intergration of components anywhere on a website
  For example you can plug "Web Components" into your static site; like sliders, accordians.
  The flexibity is endless; allowing MVC to be used from small web components to full scale one page web apps. 
  
  TweakJS wraps its Models, Views, Templates, and Controllers into a component module.
  The component module acts inteliigently to build up your application with simple config files. 
  Each component its built through a config object; this allows for powerfull configuration with tonnes of flexibity.

  Each component can have sub components which are accessible in both directions; although it is recommended to keep functionality seperate
  it sometimes comes in handy to have access to other parts of the application.

  Each component can extend another component, which will then inheret the models, views, templates, and controllers directly from that component. 
  If you however want to extend a component yet using a different Model you can simply overrite that model, or extend the functionality to the components model.
  
  The config objects are extremely handy for making components reusable, with easy accessable configuration settings.

###

class tweak.Component   
  constructor: (relation, name) ->   
    # Build relation if window and build its default properties
    # The relation is it direct caller
    relation = @relation = if relation is window then {} else relation
    relation.relation ?= {}
    # Get parent component
    @parent = if relation instanceof tweak.Components then relation.relation else relation
    # Set name of component
    @name = name or ""

    @config = @buildConfig() or {}

    # The config file can prevent automatic build and start of componets      
    if not @config.preventStart
      # Start the construcion of the component
      @start()


  tweak.Extend(@, ['require', 'findModule', 'trigger', 'on', 'off', 'clone', 'same', 'combine', 'splitComponents', 'relToAbs'], tweak.Common)
  ### 
    Description:
      Builds the config component
      It inteligently iherits modules, and configuartion settings from its extending components
  ###
  buildConfig: ->  
    configs = []    
    paths = @paths = []
    # Gets all configs, by configs extension path
    config = @name
    while config
      requested = @require "#{config}/config"
      # Store all the paths
      paths.push config
      # Push a clone of the config file to remove reference
      configs.push @clone(requested)
      config = requested.extends

    # Combine all the config files into one
    # The values of the config files from lower down the chain have piortiy
    result = configs[configs.length-1]
    for i in [configs.length-2..0]
      result = @combine(result, configs[i])

    # Set initial values in config if they do not exist
    result.model ?= {}
    result.view ?= {}
    result.controller ?= {}
    result.components ?= []
    result.events ?= {}
    result

    ### 
      Description:
        This initiates the construction and initialisation of the component. 
    ###
    start: ->
      @construct()
      @init()

    ### 
      Params: name:String, surrogate:Object, params...
      Description: Add a module to the component
      If module can't be found then it will use a surrogate object
    ###
    addModule: (name, surrogate, params...) ->
      module = @[name] = new @findModule(@paths, name, surrogate)(params...)
      module.component = module.relation = @
      module.config = @config[name]
      module

    ###
      Shortcut function to adding view
    ###
    addView: (params...) -> @addModule("view", tweak.View, params...)

    ###
      Shortcut function to adding Model
    ###
    addModel: (params...) -> @addModule("model", tweak.Model, params...)

    ###
      Shortcut function to adding controller
    ###
    addController: (params...) -> @addModule("controller", tweak.Controller, params...)

    ###
      Shortcut function to adding components
    ###
    addComponents: (params...) -> @addModule("components", tweak.Components, params...)

    ###
      Shortcut function to adding router
    ###
    addRouter: (params...) -> @addModule("router", tweak.Router, params...)


    ###
      Constructs the component and its modules
    ###
    construct: ->
      # Router is optional as it is perfomance heavy
      # So it needs to be explicility defind in the config for the component that it should be used
      if @config.router 
        @addRouter()

      # Add modules to the component
      @addModel()
      @addView() 
      @addComponents()
      @addController()
      
      # Add references to the the modules
      for item in ["model", "view", "controller", "components", "router"]
        prop = @[name]
        for item in ["name", "model", "view", "controller", "components", "router"]
          if name is item then continue
          if prop? then prop[item] = @[item]

      # Construct the modules after they have been added
      @model.construct()
      @view.construct()
      @components.construct()
      @controller.construct()
      if @router?        
        @router.construct()
      
      true
      
    ###
      initialise the component and its modules
    ###
    init: ->
      @model.init()
      @components.init()
      @controller.init()
      if @router?
        @router.init()
      true