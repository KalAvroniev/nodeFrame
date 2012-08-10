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
  $(document.body).toggleClass "sidebar-hidden sidebar-open"
  
  # animate main body (the best way to force webkit to re-render children dom elements)
  $("#main-container, .task-status").delay((if $(document.body).hasClass("sidebar-hidden") then 200 else 0)).animate
    width: ((if $aside.hasClass("active") then "99.999" else "100")) + "%"
  , 200, ->
    
    # update fake scrollbars
    Scrollbars.updateAll()
    
    # update sticky headers
    $("#grid-view").grid "windowResize"

protrada =
  version: "3a2"
  cachedAt: 1343982244107
  scrollbars:
    elements: {}
    add: (identifier, $element, options) ->
      @elements[identifier] = $element.tinyscrollbar(options or {})

    update: (identifier, type) ->
      @elements[identifier].tinyscrollbar_update type or "relative"

    updateAll: (type) ->
      that = this
      $.each @elements, (i, v) ->
        that.update i, type


    offset: (identifier) ->
      @elements[identifier].tinyscrollbar_offset()

    remove: (identifier) ->
      @elements[identifier].children(".scrollbar").remove()

  alert:
    show: (message) ->
      $("#sys-alert").removeClass("hidden").find(".alertmsg-container").find("span").text message

    hide: ->
      $("#sys-alert").addClass "hidden"

  taskStatus:
    show: (type, message) ->
      $.pv3.growl.show type, message

    hide: ->
      $.pv3.growl.hide()

  helpBubbles:
    bubbles: {}

Scrollbars = protrada.scrollbars
TaskStatus = protrada.taskStatus
Alert = protrada.alert
HelpBubbles = protrada.helpBubbles
$(document).ready ->
  module = document.URL.substr(document.URL.lastIndexOf("/") + 1) or "home"
  if module isnt ""
    $.pv3.state.update "modules.selected", module
    $.pv3.state.get ->
      $.pv3.state.restoreModule()

  $("#ui-controls").on "click", "a", (e) ->
    classes =
      condensed: "condensed"
      downgrade: "mobile"
      helpbubbles: "help"

    e.preventDefault()
    $(document.body).toggleClass classes[@id.replace(/toggle|-/g, "")]
    $(this).toggleClass "active"
    $.pv3.state.update "system_options.toggles." + @id, $(this).hasClass("active")

  $("#toggle-condensed").toggleClass "active", $(document.body).hasClass("condensed")
  $("#toggle-downgrade").toggleClass "active", $(document.body).hasClass("mobile")
  $("#toggle-sys-menu").on "click", (e) ->
    e.preventDefault()
    $(this).add("#sys-menu").toggleClass "active"

  $("#x-sys-menu").on "click", (e) ->
    e.preventDefault()
    $("#sys-menu, #toggle-sys-menu").removeClass "active"

  $("#mode-rocker").on "click", (e) ->
    e.preventDefault()
    $("#system-rocker").find("h3").toggleClass "hidden"
    $(this).toggleClass "active"
    $.pv3.state.update "system_options.mode", $("#system-rocker").find("h3").not(".hidden").attr("id")

  $("#notifications").addClass "native"  if $(document.body).hasClass("mobile")
  Scrollbars.add "notifications", $("#notifications").not(".native"),
    lockscroll: false

  $("#spine-inner").find("nav").find("a").mouseup(->
    $(this).removeClass "active"
  ).mousedown(->
    $(this).addClass "active"
  ).mouseout ->
    $(this).removeClass "active"

  $(document).on "click", ".hide-all-bubbles", (e) ->
    e.preventDefault()
    $("#toggle-help-bubbles").trigger "click"

  $(document).on "click", ".x-help-bubble", (e) ->
    e.preventDefault()
    $(this).closest(".help-bubble-container").hide()


$(document).on "click", "#toggle-side-bar, #x-side-bar", ->
  toggleSidebar()
  
  # update the state
  $.pv3.state.update "sidebar.visible", not $(document.body).hasClass("sidebar-hidden")


# remove alert item from sidebar
$(document).on "click", ".x-alert-msg", ->
  $(this).parent().slideUp 450, ->
    $(this).remove()
    
    # update fake scrollbars
    Scrollbars.update "notifications"



# tabs
$(document).on "click", ".nav-tabs li a", (e) ->
  e.preventDefault()
  $(this).tab "show"

$(document).on "click", "#alert-msgs a", (e) ->
  e.preventDefault()
  $(this).tab "show"
  
  # update fake scrollbars
  Scrollbars.update "notifications"


# restore the state for the system options
$(document).on "restore", ->
  state = $.pv3.state.current.system_options
  sidebar = $.pv3.state.current.sidebar
  if state isnt `undefined`
    
    # toggle switches
    $.each state.toggles, (k, v) ->
      id = "#ui-controls #" + k
      $(id).click()  if (v and not $(id).hasClass("active")) or (not v and $(id).hasClass("active"))

    
    # trading/devname
    $("#system-rocker").find("h3").addClass("hidden").filter("#" + state.mode).removeClass "hidden"
    $("#mode-rocker").removeClass("active").addClass ->
      (if state.mode is "devname" then "active" else "")

  
  # sidebar
  
  # show/hide
  toggleSidebar()  if (sidebar.visible and $(document.body).hasClass("sidebar-hidden")) or (not sidebar.visible and not $(document.body).hasClass("sidebar-hidden"))  if sidebar.visible isnt `undefined`  if sidebar isnt `undefined`
