$.app = {}
$.app.growl = {}
$.app.growl.hide = ->
  $(".task-status").removeClass("active").css("display", "none")
  return

###
@param type "success" or "error"
@param message HTML message (can be raw text)
###
$.app.growl.show = (type, message) ->
  $.app.growl.hide()
  $(".task-status." + type).css("display", "block").addClass("active")
  $(".status-content h2").html(type).next().html(message)
  return

$.app.state = {}
$.app.state.get = (success, options) ->
  $.jsonrpc("user/get-state"
    , {}
    , ((data) ->
      if data isnt `undefined`
        $.app.state.current = data
        success() if success
        $(document).ready ->
          $(this).trigger("restore")
          return
      return
    )
    , ((error) ->
      console.error error
      return
    )
    , options
  )
  return

$.app.state.restoreModule = ->
  module = (if (not $.app.state.current.modules.selected or $.app.state.current.modules.selected is "") then "home" else $.app.state.current.modules.selected)

  # TODO: fix!
  # for some reason module has an # appended?
  module = module.replace("#", "")
  window.history.pushState("", module, "/" + module)
  $("#main-container").trigger("ajaxUnload")
  $.app.state.update("modules.selected", module)
  $.ajax("/modules/" + module + "?ajax=1"
    , 
      success: (data) ->
        $("#ajax-container").html(data)
        $(".selected").removeClass("selected")
        $("#spine-inner nav li a#nav-" + module).parent().addClass("selected")
        $(".ajax-spinner").hide()

        # restore panels
        modules = $.app.state.current.modules
        $.app.panel.show modules[modules.selected].panel.active.url, modules[modules.selected].panel.active.options if modules[modules.selected] isnt `undefined` and modules[modules.selected].panel isnt `undefined` and modules[modules.selected].panel.active?
        return
  )
  return

$.app.state.restore = ->
  $(document).ready ->
    if $.app.state.current is `undefined`
      $.app.state.get ->
        $.app.state.restoreModule $.app.state.current.modules if $.app.state.current.modules isnt `undefined` and $.app.state.current.modules.selected isnt `undefined`
        return
        
    return
    
  return

$.app.state.update = (stateName, stateValue) ->
  $.jsonrpc("user/update-state"
    ,  
      name: stateName
      value: stateValue
    , ((result) ->
      $.app.state.current = result
      return
    )
    , (error) ->
      console.error error
      return
  )
  return

toggleSidebar = () ->
  $aside = $("aside")
  $aside.toggleClass("active")
  $(document.body).toggleClass("sidebar-hidden sidebar-open")
  $("#main-container, .task-status")
    .delay(((if $(document.body).hasClass("sidebar-hidden") then 200 else 0)))
    .animate(
        width: ((if $aside.hasClass("active") then "99.999" else "100")) + "%"
      , 200
      , ->
        # update fake scrollbars
        Scrollbars.updateAll()
        # update sticky headers
        $("#grid-view").grid "windowResize"
        return
    )
  return

protrada =
  version: "3a2"
  cachedAt: 1343982244107
  scrollbars:
    elements: {}
    add: (identifier, $element, options) ->
      @elements[identifier] = $element.tinyscrollbar(options or {})
      return

    update: (identifier, type) ->
      @elements[identifier].tinyscrollbar_update type or "relative"
      return

    updateAll: (type) ->
      that = this
      $.each @elements, (i, v) ->
        that.update i, type
        return

      return

    offset: (identifier) ->
      @elements[identifier].tinyscrollbar_offset()

    remove: (identifier) ->
      @elements[identifier].children(".scrollbar").remove()
      return

  alert:
    show: (message) ->
      $("#sys-alert").removeClass("hidden").find(".alertmsg-container").find("span").text(message)
      return

    hide: ->
      $("#sys-alert").addClass("hidden")
      return

  taskStatus:
      show: (type, message) ->
        $.app.growl.show(type, message)
        return

      hide: ->
        $.app.growl.hide()
        return

  helpBubbles:
    bubbles: {}

  panels:
    store: {}

    curPanelID: null
    prevPanelID: null

    defaultPanel: null

    defaults:
      default: false
      temporary: false
      extraClasses: null

    init: ->
      $( document ).on "click", ".panel-tab", ( e ) ->
          e.preventDefault()
          Panels.show $( this ).data()
          return

      $( document ).on "click", ".x-panel", ( e ) ->
          e.preventDefault()
          Panels.hide()
          return

      return

    add: ( options, showImmediately=false ) ->
      options = $.extend({}, @defaults, options)
      
      # these are required values
      return if options.id is undefined or options.url is undefined or options.size is undefined

      # panel already exists
      return if $( "#" + options.id ).length
      
      # temporary tabs cannot be a default tab
      if options.temporary
        options.default = false

      tabContainer = $("#main").find(".sectional-tabs")

      # TODO: move HTML string to a Jade template
      # or clone existing tab and overwrite values
      tabHTML = '<li id="' + options.id + '" class="' + (if options.default or showImmediately then "standout-tab" else "") +
        (if options.temporary then " temporary-tab" else "") + '"><a href="#" data-id="' +
        options.id + '" data-url="' + options.url + '" data-size="' +
        options.size + '"' + (if options.temporary then ' data-temporary="true"' else "") +
        (if options.extraClasses then ' data-extra-classes="' + options.extraClasses + '"' else "") +
        ' class="panel-tab"><strong>' + options.h1 + '</strong>' + options.h2 + '</a></li>'

      # must prepend - tabs are floated right
      tabContainer.prepend( tabHTML )

      # remove existing default tab if necessary
      if options.default
        @defaultPanel = $( "#" + options.id )
        tabContainer.find(".standout-tab").not( @defaultPanel ).removeClass("standout-tab")

      # show the panel straight away?
      if showImmediately
        @show( options )
      else
        @shuffle()

      return

    remove: ( id, empty=false ) ->
      tabToClose = $("#main").find(".sectional-tabs").find( "#" + id )

      # is the panel we want to remove currently open?
      # then make sure to close the panel
      if tabToClose.hasClass("active")
        empty = true # fall through to block below
        @hide()

      # usually only necessary if removing an active temporary tab
      if empty
        $("#panel-content").find(".ajax-panel-content").empty()

      tabToClose.remove()

      return

    show: ( data ) ->
      # hide any open panels
      @hide()

      # are we clicking on the previous panel? then exit
      return if @prevPanelID is data.id

      $.ajax data.url, success: ( html ) ->
        $("#section-panel").addClass("hidden")
        $("#ajax-container").prepend( html )
        $("#main").find(".sectional-tabs").find( "#" + data.id ).addClass("active")

        # no tab should have the .standout-tab class when a panel is open
        Panels.defaultPanel = $("#main").find(".sectional-tabs").find(".standout-tab").removeClass("standout-tab")
        Panels.shuffle()

        # TODO: should we be accessing the global Panels to do this?
        Panels.curPanelID = data.id
        return

      return

    hide: ->
      temporaryTab = $("#main").find(".sectional-tabs").find(".temporary-tab")
      $("#main").find(".sectional-tabs").find(".active").removeClass("active")
      $("#section-panel").addClass("hidden")
      $("#section-panel").delay(300).queue ->
        $("#section-panel.hidden").remove()
        return

      @defaultPanel.addClass("standout-tab") if @defaultPanel
      @prevPanelID = @curPanelID
      @curPanelID = null
      @remove @prevPanelID, true if temporaryTab.length and @prevPanelID is temporaryTab.attr("id")
      return      

    shuffle: ->
      tabContainer = $("#main").find(".sectional-tabs")

      # standout and/or active tab must always be the first element
      # we are presuming that there will only every be one tab found
      tabContainer.find(".standout-tab, .active").detach().prependTo( tabContainer )
      return

Scrollbars = protrada.scrollbars
TaskStatus = protrada.taskStatus
Alert = protrada.alert
HelpBubbles = protrada.helpBubbles
Panels = protrada.panels

# sidebar open/close handler
$( document ).on "click", "#toggle-side-bar, #x-side-bar", ->
    toggleSidebar()

    # update the state
    $.app.state.update "sidebar.visible", not $( document.body ).hasClass "sidebar-hidden"

    return

# TODO: mode into own sidebar "class"
# remove alert item from sidebar
$( document ).on "click", ".x-alert-msg", ->
    $( this ).parent().slideUp 450, ->
        $( this ).remove()

        # update fake scrollbars
        Scrollbars.update "notifications"
        return

    return

# TODO: shouldn't this be taken care of by twitter bootstrap?
# tabs
$( document ).on "click", ".nav-tabs li a", ( e ) ->
    e.preventDefault()
    $( this ).tab "show"
    return

$( document ).on "click", "#alert-msgs a", ( e ) ->
    e.preventDefault()
    $( this ).tab "show"

    # update fake scrollbars
    Scrollbars.update "notifications"

    return

# restore the state for the system options
$( document ).on "restore", ->
    state = $.app.state.current.system_options
    sidebar = $.app.state.current.sidebar

    if state isnt undefined
      # toggle switches
      $.each state.toggles, ( k, v ) ->
          id = "#ui-controls #" + k

          if ( (v and not $( id ).hasClass("active")) or (not v and $( id ).hasClass("active")) )
            $( id ).click()
          return

      # trading/devname
      $("#system-rocker").find("h3").addClass("hidden").filter( "#" + state.mode ).removeClass "hidden"
      $("#mode-rocker").removeClass("active").addClass ->
        if state.mode is "devname" then "active" else ""

    # sidebar show/hide
    if sidebar isnt undefined and sidebar.visible isnt undefined
      toggleSidebar()

    return

togglePanel = (selectorName, contentCallback) ->
  $this = $(this)
  $panel = $("#section-panel")
  if $panel.data("tab") is selectorName
    $panel.addClass("hidden").removeData("tab")
  else
    if $panel.hasClass("hidden")
      $panel.removeClass("hidden")
    else
      $this.siblings().removeClass("active")
  
    $panel.html(contentCallback()).data("tab", selectorName)

  if $panel.hasClass("hidden")
    $this.removeClass("active")
  else
    $this.addClass("active")
  return

NotificationsController = (notifications) ->
  @notifications = notifications
  return

verticalScroll = "body"
Number::toMoney = (decimals, decimal_sep, thousands_sep) ->
  n = this
  c = (if isNaN(decimals) then 2 else Math.abs(decimals))
  d = decimal_sep or "."
  t = (if (typeof thousands_sep is "undefined") then "," else thousands_sep)
  sign = (if (n < 0) then "-" else "")
  i = parseInt(n = Math.abs(n).toFixed(c)) + ""
  j = (if ((j = i.length) > 3) then j % 3 else 0)
  sign + ((if j then i.substr(0, j) + t else "")) + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + ((if c then d + Math.abs(n - i).toFixed(c).slice(2) else ""))

NotificationsController::render = ->
  ns = @notifications
  $.jade.getTemplate("notifications/generic"
    , ((fn) ->
      $("#protrada-msgs.no-alerts").removeClass("no-alerts").find(".alerts-listing").html(" ")
      i = 0

      while i < ns.length
        notif = $.jade.renderSync(fn, ns[i])
        $("#protrada-msgs").append(notif)
        ++i
        
      $("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr("data-alerts", ns.length)
      $(".protrada .alert-count").attr("data-alerts", ns.length)
      Scrollbars.update("notifications")
      return  
    )
    , (error) ->
      alert error
      return
  )
  return

###
$(document).ready ->
  module = document.URL.substr(document.URL.lastIndexOf("/") + 1) or "home"
  if module isnt ""
    $.app.state.update("modules.selected", module)
    $.app.state.get ->
      $.app.state.restoreModule()
      return

  $("#ui-controls").on("click"
    , "a"
    , (e) ->
      classes =
        condensed: "condensed"
        downgrade: "mobile"
        helpbubbles: "help"

      e.preventDefault()
      $(document.body).toggleClass(classes[@id.replace(/toggle|-/g, "")])
      $(this).toggleClass("active")
      $.app.state.update("system_options.toggles." + @id, $(this).hasClass("active"))
      return
  )
  $("#toggle-condensed").toggleClass("active", $(document.body).hasClass("condensed"))
  $("#toggle-downgrade").toggleClass("active", $(document.body).hasClass("mobile"))
  $("#toggle-sys-menu").on("click"
    , (e) ->
      e.preventDefault()
      $(this).add("#sys-menu").toggleClass("active")
      return
  )
  $("#x-sys-menu").on("click"
    , (e) ->
      e.preventDefault()
      $("#sys-menu, #toggle-sys-menu").removeClass("active")
      return
  )
  $("#mode-rocker").on("click"
    , (e) ->
      e.preventDefault()
      $("#system-rocker").find("h3").toggleClass("hidden")
      $(this).toggleClass("active")
      $.app.state.update("system_options.mode", $("#system-rocker").find("h3").not(".hidden").attr("id"))
      return
  )

  $("#notifications").addClass("native") if $(document.body).hasClass("mobile")
  Scrollbars.add("notifications"
    , $("#notifications").not(".native")
    ,
      lockscroll: false
  )
  $("#spine-inner").find("nav").find("a").mouseup(->
    $(this).removeClass("active")
    return
  ).mousedown(->
    $(this).addClass("active")
    return    
  ).mouseout(->
    $(this).removeClass("active")
    return    
  )

  $(document).on("click"
    , ".hide-all-bubbles"
    , (e) ->
      e.preventDefault()
      $("#toggle-help-bubbles").trigger("click")
      return
  )
  $(document).on("click"
    , ".x-help-bubble"
    , (e) ->
      e.preventDefault()
      $(this).closest(".help-bubble-container").hide()
      return
  )
  $(".dropdown-toggle").dropdown()
  $(window).resize ->
    Scrollbars.update("notifications")
    return
    

  $("#system-help, #live-help-status, #live-help-info > a").on("click"
    , (e) ->
      e.preventDefault()
      TaskStatus.show("error", "The Live Help system is coming soon.")
      return
  )

  document.socketio = io.connect("http://" + location.host)
  document.socketio.on("logout"
    , ->
      document.location = "/login"
      return    
  )

  $.jsonrpc("notifications/fetch"
    , {}
    , (data) ->
      notif = new NotificationsController(data.notifications)
      notif.render()
      document.socketio.on("notification"
        , (msg) ->
          notif.notifications.unshift(msg.data)
          notif.render()
          return    
      )
      return
  )
  return
###