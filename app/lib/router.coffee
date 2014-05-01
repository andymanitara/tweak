### 
  ----- ROUTER -----


###

class tweak.Router      

  extend(@, ['trigger', 'on', 'off', 'init'], Common)
  construct: ->
    @before = '#'
    if history.pushState then history.pushState null, null, ''


  ### 
    Description:      
  ###  
  start: (options = {}) ->
    speed = options.speed or 50
    quiet = options.quiet
    check = @check
    @watch = setInterval =>
      @check(quiet)
    , speed
    return
  
  ### 
    Description:      
  ###
  stop: -> clearInterval(@watch); return
  
  ### 
    Description:      
  ###
  check: (options = {}) ->
    hash = window.location.hash.substring 1
    data = 'data'
    quiet = options.quiet
    if hash isnt @before
      hashArr = []
      @before = hash
      if @ignore is true
        @ignore = false
        return
      @ignore = false

      for item in hash.split('/')
        itemArr = item.split(':')
        if itemArr.length is 1
          hashArr.push itemArr[0]
          if not quiet then @trigger "#{@name}:router:data:"+itemArr[0]
        else
          object = {}
          object[itemArr[0]] = itemArr[1]
          hashArr.push object         
          if not quiet then @trigger "#{@name}:router:data:"+itemArr[0], object[itemArr[1]]
      if not quiet then @trigger "#{@name}:router:changed", hashArr
    return
  
  ### 
    Description:      
  ###
  set: (arr, options = {}) -> 
    location = ''
    for item in arr
      if typeof item isnt 'object' then location += item
      else 
        itemArr = []
        for key, prop of item
          itemArr.push key, prop
        location += itemArr[0] + ':' + itemArr[1]
      location += '/'
    @ignore = options.quiet
    window.location.hash = location.slice 0, -1
    return

  mask: (arr) -> @set(arr, {quiet:true})