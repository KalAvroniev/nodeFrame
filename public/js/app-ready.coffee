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
	
  $(".dropdown-toggle").dropdown()
  $(window).resize ->
    Scrollbars.update "notifications"
    return

  $("#system-help, #live-help-status, #live-help-info > a").on "click", (e) ->
    e.preventDefault()
    TaskStatus.show "error", "The Live Help system is coming soon."
    return

  document.socketio = io.connect("http://" + location.host)
  document.socketio.on "logout", ->
    document.location = "/login"
    return		

  $.jsonrpc "notifications/fetch", {}, (data) ->
    notif = new NotificationsController(data.notifications)
    notif.render()
    document.socketio.on "notification", (msg) ->
      notif.notifications.unshift msg.data
      notif.render()
      return		
    return
  return