### 
  ----- CONTROLLER -----
  The controller should be used to control the logic and functionality between components modules.
###
class tweak.Controller
  tweak.Extend(@, ['require', 'findModule', 'trigger', 'on', 'off', 'clone', 'same', 'combine', 'splitComponents', 'relToAbs', 'init'], tweak.Common)
  construct: ->
  

  ###
    Renders itself and its subcomponents
    It has a built in component:ready event trigger; this allows you to perform your logic once things are defiantly ready
  ###
  render: ->
    @on("#{@name}:view:rendered", =>
      @on("#{@name}:components:ready", => @trigger("#{@name}:ready", @name))        
      @components.render()
    )     
    @view.render()

  ###
    Renders itself and its subcomponents
    It has a built in component:ready event trigger; this allows you to perform your logic once things are defiantly ready
  ###
  rerender: ->
    @on("#{@name}:view:rendered", =>
      @on("#{@name}:components:ready", => @trigger("#{@name}:ready", @name))
      @components.rerender() 
    )     
    @view.rerender()    
  
  ### 
    Parameters:   co:Object
    Description:  Destroy this component. It will clear the view if it exists; and removes it from collection if it is part of one
  ###
  destroy: (options = {}) ->
    if @view? then @view.clear()
    components = @relation.components
    if components? then components.remove @name, options
    return
