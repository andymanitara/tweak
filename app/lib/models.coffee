### 
----- Models -----

###   

class tweak.Models extends tweak.Collection
  of:'models'
  tweak.Extend(@, ['require','splitComponents', 'findModule', 'relToAbs', 'buildModule', 'addReferences'], tweak.Common)

  ### 
    Parameters: data:Object 
    Description: Construct the Collection with given options  
  ### 
  construct: ->
    super()
    for key, prop of @config
      @addModel(key)

  ###
    Shortcut function to adding controller
  ###
  addModel: (path, params...) ->
    model = @buildModule(path, tweak.Model, params...)
    @add(model)
    @addReferences(model)
    model.construct()