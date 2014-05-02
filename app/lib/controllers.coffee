### 
----- Controllers -----

###   

class tweak.Controllers extends tweak.Collection
  of:'controllers'
  tweak.Extend(@, ['require','splitComponents', 'findModule', 'relToAbs', 'buildModule', 'addReferences'], tweak.Common)

  ### 
    Parameters: data:Object 
    Description: Construct the Collection with given options  
  ### 
  construct: ->
    super()
    controllers = @config or ["controller"]
    for item in controllers
      @addController(item)

  ###
    Shortcut function to adding controller
  ###
  addController: (path, params...) ->
    controller = @buildModule(path, tweak.Controller, params...)
    @addReferences(controller)
    @add(controller)