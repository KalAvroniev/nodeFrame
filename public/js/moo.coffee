# crude method of keeping track of fake scrollbars
# will redo much better at some point when other "state machines" are worked out
# toggle body class
# toggle active UI state
# update the state
# toggle between Protrada and Devname
# toggle active UI state
# update the state
# special class for the side-bar on mobile devices
# we've already checked for mobile by this stage (index.jade), so rely on class present on body
# init fake scrollbars on sidebar
# PETE: Please don't delete this script:
# UX improvement on the spine nav buttons
# setup open/close sidebar element functions

toggleSidebar = (e) ->
  $aside = $("aside")
  $aside.toggleClass "active"
  $(document.body).toggleClass ("sidebar-hidden sidebar-open")
  $("#main-container, .task-status")
    .delay((if $(document.body).hasClass("sidebar-hidden") then 200 else 0))
    .animate 
			width: ((if $aside.hasClass("active") then "99.999" else "100")) + "%", 200, ->
            # update fake scrollbars
            Scrollbars.updateAll()
            # update sticky headers
            $("#grid-view").grid "windowResize"
						      return
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
      return

    remove: (identifier) ->
      @elements[identifier].children(".scrollbar").remove()
      return

  alert:
    show: (message) ->
      $("#sys-alert").removeClass("hidden").find(".alertmsg-container").find("span").text message
      return
			
    hide: ->
      $("#sys-alert").addClass "hidden"
      return

  taskStatus:
    show: (type, message) ->
      $.app.growl.show type, message
      return

    hide: ->
      $.app.growl.hide()
      return

  helpBubbles:
    bubbles: {}

Scrollbars = protrada.scrollbars
TaskStatus = protrada.taskStatus
Alert = protrada.alert
HelpBubbles = protrada.helpBubbles
$(document).ready ->
  module = document.URL.substr(document.URL.lastIndexOf("/") + 1) or "home"
  if module isnt ""
    $.app.state.update "modules.selected", module
    $.app.state.get ->
      $.app.state.restoreModule()
      return

  $("#ui-controls").on "click", "a", (e) ->
    classes =
      condensed: "condensed"
      downgrade: "mobile"
      helpbubbles: "help"

    e.preventDefault()
    $(document.body).toggleClass classes[@id.replace(/toggle|-/g, "")]
    $(this).toggleClass "active"
    $.app.state.update "system_options.toggles." + @id, $(this).hasClass("active")
    return

  $("#toggle-condensed").toggleClass "active", $(document.body).hasClass("condensed")
  $("#toggle-downgrade").toggleClass "active", $(document.body).hasClass("mobile")
  $("#toggle-sys-menu").on "click", (e) ->
    e.preventDefault()
    $(this).add("#sys-menu").toggleClass "active"
    return

  $("#x-sys-menu").on "click", (e) ->
    e.preventDefault()
    $("#sys-menu, #toggle-sys-menu").removeClass "active"
    return
		
  $("#mode-rocker").on "click", (e) ->
    e.preventDefault()
    $("#system-rocker").find("h3").toggleClass "hidden"
    $(this).toggleClass "active"
    $.app.state.update "system_options.mode", $("#system-rocker").find("h3").not(".hidden").attr("id")
    return
		
  $("#notifications").addClass "native"  if $(document.body).hasClass("mobile")
  Scrollbars.add "notifications", $("#notifications").not(".native"),
    lockscroll: false
		
  $("#spine-inner").find("nav").find("a").mouseup(->
    $(this).removeClass "active"
    return
  ).mousedown(->
    $(this).addClass "active"
    return		
  ).mouseout ->
    $(this).removeClass "active"
    return		

  $(document).on "click", ".hide-all-bubbles", (e) ->
    e.preventDefault()
    $("#toggle-help-bubbles").trigger "click"
    return

  $(document).on "click", ".x-help-bubble", (e) ->
    e.preventDefault()
    $(this).closest(".help-bubble-container").hide()
    return
  return

$(document).on "click", "#toggle-side-bar, #x-side-bar", ->
  toggleSidebar()
  
  # update the state
  $.app.state.update "sidebar.visible", not $(document.body).hasClass("sidebar-hidden")
  return

# remove alert item from sidebar
$(document).on "click", ".x-alert-msg", ->
  $(this).parent().slideUp 450, ->
    $(this).remove()

    # update fake scrollbars
    Scrollbars.update "notifications"
    return
  return

# tabs
$(document).on "click", ".nav-tabs li a", (e) ->
  e.preventDefault()
  $(this).tab "show"
  return    
		
$(document).on "click", "#alert-msgs a", (e) ->
  e.preventDefault()
  $(this).tab "show"
  
  # update fake scrollbars
  Scrollbars.update "notifications"
  return

# restore the state for the system options
$(document).on "restore", ->
  state = $.app.state.current.system_options
  sidebar = $.app.state.current.sidebar
  if state isnt `undefined`
    
    # toggle switches
    $.each state.toggles, (k, v) ->
      id = "#ui-controls #" + k
      $(id).click()  if (v and not $(id).hasClass("active")) or (not v and $(id).hasClass("active"))
      return			

    
    # trading/devname
    $("#system-rocker").find("h3").addClass("hidden").filter("#" + state.mode).removeClass "hidden"
    $("#mode-rocker").removeClass("active").addClass ->
      if state.mode is "devname" then "active" else ""

  
  # sidebar
  
  # show/hide
  toggleSidebar()  if (sidebar.visible and $(document.body).hasClass("sidebar-hidden")) or (not sidebar.visible and not $(document.body).hasClass("sidebar-hidden"))  if sidebar.visible isnt `undefined`  if sidebar isnt `undefined`
  return
