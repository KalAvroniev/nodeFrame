$(document).ready ->
  
  # --- save state
  $("#user-settings-tabs li a").click (e) ->
    $.pv3.state.update "modules.user-settings.tabs.selected", e.currentTarget.id

  
  # General / user settings
  $("#general-tabs li a").click (e) ->
    mainTab = $("#user-settings-tabs li.active a")[0].id
    $.pv3.state.update "modules.user-settings.tabs." + mainTab + ".tabs.selected", e.currentTarget.id

  
  # update counter
  $("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr "data-alerts", $(".protrada .alert-count").attr("data-alerts")


# --- restore state
$(document).on "restore", ->
  
  # restore tabs
  state = $.pv3.state.current
  return  if state.modules["user-settings"] is `undefined`
  tabs = state.modules["user-settings"].tabs
  return  if tabs is `undefined`
  
  # change selected tab
  $("#user-settings-tabs li a#" + tabs.selected).click()  unless tabs.selected is `undefined`
  
  # General / user settings
  if tabs.selected is "general-btn"
    return  if tabs["general-btn"] is `undefined` or tabs["general-btn"].tabs is `undefined` or tabs["general-btn"].tabs.selected is `undefined`
    $("#general-tabs li a#" + tabs["general-btn"].tabs.selected).click()
    return
  
  # External account linkage
  return  if tabs.selected is "external-accounts-btn"
  
  # System notification settings
  return  if tabs.selected is "sys-notifications-btn"


# external account button UI behaviour
$(".account-selection").on "click", "li:not(.open-for-edit, .more-coming-soon)", (e) ->
  e.preventDefault()
  if $(this).hasClass("active")
    $(this).removeClass "active"
  else
    $(this).siblings().removeClass("active").end().addClass "active"

$.pv3.state.get()