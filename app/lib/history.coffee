###
  Simple cross browser history API. Upon changes to the history a change event is
  called. The ability to hook event listeners to the tweak.History API allows
  routes to be added accordingly, and for multiple Routers to be declared for
  better code structure.

  Examples are in JS, unless where CoffeeScript syntax may be unusual. Examples
  are not exact, and will not directly represent valid code; the aim of an example
  is to show how to roughly use a method.
###
class tweak.History extends tweak.Events
  usePush: true
  useHash: false
  started: false
  root: "/"
  iframe: null
  url: null
  __interval: null
  intervalRate: 50

  ###
    Checks that the window and history is available.
    This addr support for the history to work outside of browsers
    if the window, history and location are set manually.
  ###
  constructor: ->
    if typeof window isnt "undefined"
      @location = (@window = window).location
      @history = window.history

  ###
    Start listening to the URL changes to push back the history API if available.
    
    @param [Object] options An optional object to pass in optional arguments
    @option options [Boolean] pushState (default = true) Specify whether to use pushState if false then hashState will be used.
    @option options [Boolean] hashState (default = false) Specify whether to use hashState if true then pushState will be set to false.
    @option options [Boolean] forceRefresh (default = false) When set to true then pushState and hashState will not be used.
    @option options [Number] interval (default = null) When set to a number this is what the refresh rate will be when an interval has to be used to check changes to the URL.
    @option options [Boolean] silent (default = false) If set to true then an initial change event trigger will not be called.
    
    @event changed When the URL is updated a change event is fired from tweak.History.

    @example Starting the history with auto configuration.
      tweak.History.start();

    @example Starting the history with forced HashState.
      tweak.History.start({
        hashState:true
      });

    @example Starting the history with forced PushState.
      tweak.History.start({
        pushState:true
      });

    @example Starting the history with forced refresh or page.
      tweak.History.start({
        forceRefresh:true
      });

    @example Starting the history with an interval rate for the polling speed for older browsers.
      tweak.History.start({
        hashState:true,
        interval: 100
      });

    @example Starting the history silently.
      tweak.History.start({
        hashState:true,
        silent: true
      });
  ###
  start: (options = {}) ->
    # Check if tweak.History is already started
    # If started then return
    return if @started
    @started = true

    # Set usePush and useHash based on the options passed in.
    @usePush = usePush = not useHash = @useHash = options.hashState or not options.pushState or not @history?.pushState

    # Make sure using one state or the other
    if usePush is true then @useHash = useHash = false

    # If the page is to be refreshed on a navigation event then set both useHash and usePush to false
    if options.forceRefresh or (useHash and not `('onhashchange' in this.window)`) then @usePush = @useHash = useHash = usePush = false

    # Set the interval rate for older browsers
    @intervalRate = options.interval or @intervalRate


    # Set the normalized root for the history to check against.
    @root = root = ("/#{options.root or "/"}/").replace /^\/+|\/+$/g, "/"
    # Get the current URL
    @url = url = @__getURL()
    location = @location
    atRoot = @__atRoot()
    # Validate the hash state - if not at root then replace URL with root & hash
    if useHash and not atRoot
      root = root.slice(0, -1) or "/"
      @location.replace "#{root}##{@__getPath()}"
      # Return immediately as browser has now triggered URL change
      return

    # Validate the push state - if not at root she replace URL with root
    else if usePush and atRoot
      @set @__getHash(), {replace: true}

    # If the browser doesn't support hash or pushState and it isn't being forced to be refreshed
    if not usePush and not useHash and not options.forceRefresh
      # Creates a simple iframe element attaching to the body to trick IE into having a usable history
      frame = document.createElement "iframe"
      frame.src = "javascript:0"
      frame.style.display = "none"
      frame.tabIndex = -1
      body = document.body
      @iframe = body.insertBefore(frame, body.firstChild).contentWindow
      @__setHash @iframe, "##{url}", false

    @__toggleListeners()
    if not options.silent then return @triggerEvent "changed", @url
  
  ###
   Stop tweak.History. Most likely useful for a web component that uses the history to change state,
   but if removed from page then component may want to stop the history.
  ###
  stop: ->
    @__toggleListeners "off"
    @started = false

  ###
    Set the URL and add the URL to history.
    
    @param [Object] options An optional object to pass in optional arguments.
    @option options [Boolean] replace (default = false) Specify whether to replace the current item in the history.
    @option options [Boolean] silent (default = true) Specify whether to allow triggering of event when setting the URL.

    @example Setting the History (updating the URL).
      tweak.History.set("/#/fake/url");

    @example Replacing the last History state (updating the URL).
      tweak.History.set("/#/fake/url", {
        replace:true
      });

    @example Setting the History (updating the URL) and calling history change event.
      tweak.History.set("/#/fake/url", {
        silent:false
      });
  ###
  set: (url, options = {}) ->
    # If the history isn't started then return
    if not @started then return
    # Set silent option to true if it is null
    options.silent ?= true
    replace = options.replace

    # Get the current URL formatted and validated
    url = @__getURL(url) or ""

    # Get root without slash or question mark
    root = @root
    if url is "" or url.charAt(0) is "?"
      root = root.slice(0, -1) or  "/"

    # Create full URL with root
    fullUrl = "#{root}#{url}"

    # Strip the hash from the URL and decode
    url = decodeURI url.replace /#.*$/, ""

    # If the URL is the previous URL then return otherwise change current URL to current URL
    if @url is url then return
    @url = url

    # If pushState is available we can replace the current history state or add a state to the history
    if @usePush
      @history[if replace then "replaceState" else "pushState"] {}, document.title, fullUrl
    else if @useHash
      # If hash is is available then update the hash
      @__setHash @window, url, replace
      if @iframe and url isnt @__getHash @iframe
        @__setHash @iframe, url, replace
    else
      # Forces refresh of page if not using push of hash state
      # Return as the page is refreshing at that point
      @location.assign fullURL
      return
    
    # If the option not to be silent is made then send a change event
    if not options.silent then @triggerEvent "changed", @url = url
    return

  ###
    @private
    Add listeners of remove history change listeners.
    @param [String] prefix (Default = "on") Set the prefix - "on" or "off".
  ###
  __toggleListeners: (prefix = "on") ->
    # Setup or remove event triggers for when the history updates - depending on the type of state being used.
    if @pushState
      # If a pushState is available
      tweak.Common[prefix] @window, "popstate", @__checkChanged
    else if @useHash and not @iframe
      # If hashState is available and not using an iframe
      tweak.Common[prefix] @window, "hashchange", @__checkChanged

    else if @useHash
      # If using iframe and hash state
      if prefix is "on"
        @__interval = setInterval @__checkChanged, @intervalRate
      else
        clearInterval @__interval
        document.body.removeChild @iframe.frameElement
        @iframe = @__interval = null
    return

  ###
    @private
    Gets whether the URL is at the root of application.
    @return Gets whether the URL is at the root of application.
  ###
  __atRoot: ->
    path = @location.pathname.replace /[^\/]$/, "$&/"
    path is @root and not @__getSearch()

  ###
    @private
    Get the URL formatted without the hash.
    @param [Window] window The window to retrieve hash.
    @return Normalized URL without hash.
  ###
  __getHash: (window) ->
    match = (window or @).location.href.match /#(.*)$/
    return if match then match[1] else ""

  ###
    @private
    In IE6 the search and hash are wrong when it contains a question mark.
    @return search if it matches or return empty string.
  ###
  __getSearch: ->
    match = @location.href.replace(/#.*/, "").match /\?.+/
    return if match then match[0] else ""

  ###
    @private
    Get the pathname and search parameters, without the root.
    @return Normalized URL.
  ###
  __getPath: ->
    path = decodeURI "#{@location.pathname}#{@__getSearch()}"
    root = @root.slice 0, -1
    if not path.indexOf root then path = path.slice root.length
    return if path.charAt(0) is "/" then path.slice 1 else path

  ###
    @private
    Get a normalized URL.
    @param [String] URL The URL to normalize - if null then URL will be retrieved from window.location.
    @param [Boolean] force Force the returning value to be hash state.
    @return Normalized URL without trailing slashes at either side.
  ###
  __getURL: (url, force) ->
    # If the URL is null then a URL will be retrieved from window.location
    if not url?
      # If usePush or if to be forced to retrieve this format
      if @usePush or force
        # Get the URL decoded
        url = decodeURI "#{@location.pathname}#{@location.search}"
        # Get the root without trailing slash
        root = @root.replace /\/$/, ""
        # Get the URL minus the root
        if not url.indexOf(root) then url = url.slice root.length
      else
        # Get the hash
        url = @__getHash()

    # Return URL without trailing slashes
    # We may want to neaten the URL with a single prefix slash therefore it accepts 1 prefix slash
    url.replace /^\/+/g, "/"
    url.replace /^\/+$/g, ""

  ###
    @private
    Change the hash or replace the hash.
    @param [Location] location The location to amend the hash to. ieFrame.location or the window.location.
    @param [String] URL The URL to replace the current hash with.
    @param [Boolean] replace Whether to replace the hash by href or to change hash directly.
  ###
  __setHash: (window, url, replace) ->
    if @iframe is window then window.document.open().close()
    # Some browsers require that the hash contains a leading #
    if replace
      window.location.replace "#{location.href.replace /(javascript:|#).*$/, ''}##{url}"
    else
      window.location.hash = "#{url}"
    return

  ###
    @private
    Check whether the URL has been changed, if it has then trigger change event.
  ###
  __checkChanged: =>
    now = @__getURL()
    old = @url
    if now is old
      if @iframe
        now = @__getHash @iframe
        @set now
      else return false
    @triggerEvent "changed", @url = now
    true

tweak.History = new tweak.History()