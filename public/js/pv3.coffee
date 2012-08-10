# always declare variables first

# derived from http://stackoverflow.com/a/2866613
# if decimal is zero we must take it, it means user does not want to show any decimal
# if no decimal separator is passed we use the comma as default decimal separator (we MUST use a decimal separator)

# according to [http://stackoverflow.com/questions/411352/how-best-to-determine-if-an-argument-is-not-sent-to-the-javascript-function]
# the fastest way to check for not defined parameter is to use typeof value === "undefined"
# rather than doing value === undefined.
# if you don't want ot use a thousands separator you can pass empty string as thousands_sep value

# extracting the absolute value of the integer part of the number and converting to string

# dropdowns

# this must be assigned after the jade template is loaded in, see $.pv3.panel.show()
#$("#import-export, .x-panel").click(function() {
#		if ( $("#section-panel").hasClass("hidden") ) {
#			$("#section-panel").removeClass("hidden");
#			$( this ).addClass("active");
#		} else {
#			$("#section-panel").addClass("hidden")
#			$(".sectional-tabs .active").removeClass("active");
#		}
#
#		return false;
#	});

# update fake scrollbars

# now setup the socket for push notifications

# force logout

# the first thing we need to do is fetch the recent notifications

# now setup the socket for push notifications
togglePanel = (selectorName, contentCallback) ->
  $this = $(this)
  $panel = $("#section-panel")
  
  # already visible
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

# ---
# PUSH/FETCH NOTIFICATIONS
# ---
NotificationsController = (notifications) ->
  @notifications = notifications
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
  
  # if there is data, fetch the template and render
  $.jade.getTemplate "notifications/generic", ((fn) ->
    $("#protrada-msgs.no-alerts").removeClass("no-alerts").find(".alerts-listing").html " "
    i = 0

    while i < ns.length
      notif = $.jade.renderSync(fn, ns[i])
      $("#protrada-msgs").append notif
      ++i
    
    # update counter
    $("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr "data-alerts", ns.length
    $(".protrada .alert-count").attr "data-alerts", ns.length
    Scrollbars.update "notifications"
  ), (error) ->
    alert error
