###
  Web applications often provide linkable, bookmarkable, shareable URLs for important locations in the app.
  The Router module provides methods for routing to events which can control the application. Traditionaly it
  used to be that routers worked from hash fragments #page. However, the History API now provides standard
  url formats /example. Routers provide functioanlity that links applications/components/modules together 
  through data passed through the URL.

  @todo Document description
###

class tweak.Router extends tweak.EventSystem
  # @property [Integer] The uid of this object - for unique reference
  uid: 0
  # @property [Method] see tweak.super
  super: tweak.super

  ###
    The constructor initialises the controllers unique ID. 
  ###
  constructor: (hash = false, @routes = {}) ->
    @uid = "r_#{tweak.uids.r++}"
    tweak.History.addEvent "changed", @__urlChanged, null, @

  add: (event, route) ->
    if @routes[event]? then @routes[event].push route
    else @routes[event] = [route]

  remove: (event, routes) ->
    routers = @routes[event]
    for route in " #{routes.replace /\s+/g, ' '} ".split " "
      routers = " #{routers.join ' '} ".split " #{route} "
    @routes[event] = routers
    
    if not routes? or routers.length is 0
      delete @routes[event]

  __paramReg = /\/?[?:]([^?\/:]*)/g

  __getData = (segment) ->
    data = /^.*\?(.+)/.exec segment
    if data
      options = /([^&\/\\]+)[&\/\\]*/.exec data[1]
      if options        
        for option in options
          segment = {}
          props = /(.+)[:=]+(.+)|(.+)/.exec segment
          if props
            key = props[3] or props[1]
            prop = props[2] or true
            segment[key] = prop
    else
      segment = segment.replace /\?/g, ''
    segment
      
  __toRegex = (route) ->
    escapeReg = /[\-\\\^\[\]\s{}+.,$|#]/g
    splatReg = /\/?(\*)$/

    route = route.replace escapeReg, '\\$&'
    route = route.replace __paramReg, (match) ->
      res = "\\/?([^\\/]*?)"
      if /^\/?\?/.exec match then "(?:#{res})?" else res                   
    route = route.replace splatReg, '\\/?(.*?)'
    new RegExp "^#{route}[\\/\\s]?$"

  __getKeys = (route) ->
    res = route.match __paramReg
    res.push "splat"
    res
      
  __urlChanged: (url) ->
    for event, routes of @routers
      for route in routes
        keys = []       
        if typeof route is "string"
          keys = __getKeys route
          route = __toRegex route         
        if match = route.exec url   
          res = {url, data:{}}
          match.splice 0,1
          key = 0
          for item in match
            res.data[keys[key].replace(/^[?:\/]/, "") or key] = __getData item
            key++
          @triggerEvent event, res

