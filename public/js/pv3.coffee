togglePanel = (selectorName, contentCallback) ->
  $this = $(this)
  $panel = $("#section-panel")
  if $panel.data("tab") is selectorName
    $panel.addClass("hidden").removeData "tab"
  else
    if $panel.hasClass("hidden")
      $panel.removeClass "hidden"
    else
      $this.siblings().removeClass "active"
    $panel.html(contentCallback()).data "tab", selectorName
  if $panel.hasClass("hidden")
    $this.removeClass "active"
  else
    $this.addClass "active"
	
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

$(document).ready ->
  $(".dropdown-toggle").dropdown()
  $(window).resize ->
    Scrollbars.update "notifications"

  $("#system-help, #live-help-status, #live-help-info > a").on "click", (e) ->
    e.preventDefault()
    TaskStatus.show "error", "The Live Help system is coming soon."

  document.socketio = io.connect("http://" + location.host)
  document.socketio.on "logout", ->
    document.location = "/login"

  $.jsonrpc "notifications/fetch", {}, (data) ->
    notif = new NotificationsController(data.notifications)
    notif.render()
    document.socketio.on "notification", (msg) ->
      notif.notifications.unshift msg.data
      notif.render()



NotificationsController::render = ->
  ns = @notifications
  $.jade.getTemplate "notifications/generic", ((fn) ->
    $("#protrada-msgs.no-alerts").removeClass("no-alerts").find(".alerts-listing").html " "
    i = 0

    while i < ns.length
      notif = $.jade.renderSync(fn, ns[i])
      $("#protrada-msgs").append notif
      ++i
    $("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr "data-alerts", ns.length
    $(".protrada .alert-count").attr "data-alerts", ns.length
    Scrollbars.update "notifications"
	
  ), (error) ->
    alert error
  return
