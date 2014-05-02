### 
----- Views -----

###   

class tweak.Views extends tweak.Collection
  of:'views'
  tweak.Extend(@, ['require','splitComponents', 'findModule', 'relToAbs', 'buildModule', 'addReferences'], tweak.Common)

  ### 
    Parameters: data:Object 
    Description: Construct the Collection with given options  
  ### 
  construct: ->
    super()
    @on('#{@name}:#{@of}:ready', => 
    	@init()
	    for item in @data
	      item.init()
    )
    for key, prop of @config
      @addView(key)

  ###
    Shortcut function to adding controller
  ###
  addView: (path, params...) ->
    view = @buildModule(path, tweak.View, params...)
    @add(view)
    @addReferences(view)
    view.construct()

  render: ->
    if @length() is 0
      @trigger("#{@name}:#{@of}:ready")
      return
    total = 0
    totalItems = @data.length
    for item in @data
      item.render()
      @on("#{item.name}:view:rendered", =>
        total++
        if total >= totalItems then @trigger("#{@name}:#{@of}:ready")
      )

  rerender: ->
    if @length() is 0
      @trigger("#{@name}:#{@of}:ready")
      return
    total = 0
    totalItems = @data.length
    for item in @data
      item.rerender()
      @on("#{item.name}:view:rendered", =>
        total++
        if total >= totalItems then @trigger("#{@name}:#{@of}:ready")
      )
