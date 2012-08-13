# install JSON-RPC client
$.jsonrpc = (method, params, success, failure, options) ->
  options = options or {}
  success = success or $.noop
  failure = failure or (errMsg, errCode) ->
    console.error "Error " + errCode + ": " + errMsg

  ajax =
    type: "POST"
    url: "/jsonrpc"
    processData: false
    dataType: "json"
    data: JSON.stringify(
      jsonrpc: "2.0"
      method: method
      params: params
      id: 1
    )
    success: (result) ->
      if result.error isnt `undefined` and result.error.message
        document.location = "/login"  if result.error.message.substr(0, 8) is "!logout:"
        return failure(result.error.message, result.error.code)
      success result.result

    error: (jqXHR, textStatus, errorThrown) ->
      failure textStatus, 0

  ajax.async = options.async  if options.async isnt `undefined`
  $.ajax ajax
  return

$.jsonrpcSync = (method, params, success, failure, options) ->
  options = options or {}
  options.async = false
  $.jsonrpc method, params, success, failure, options

$.ajaxPanel = (url, success, failure) ->
  failure = failure or (errMsg, errCode) ->
    console.error "Error " + errCode + ": " + errMsg
  $.ajax({
    type: "GET"
    url: url
    processData: false
    success: success
  })
  return


$.jade = {}
$.jade.getTemplate = (url, success, options) ->
  
  # is it already loaded?
  fnRaw = url.replace(/[\/-]/g, "_")
  fn = undefined
  fnRaw = fnRaw.substr(1)  if fnRaw.charAt(0) is "_"
  fn = "views_" + fnRaw
  return success(fn)  if document[fn] isnt `undefined`
  
  # we need to load it
  $.ajax({
    url: url + ".jade"
    dataType: "script"
    success: ->
      fnRaw = url.replace(/[\/-]/g, "_")
      fn = undefined
      fnRaw = fnRaw.substr(1)  if fnRaw.charAt(0) is "_"
      fn = "views_" + fnRaw
      success fn

    failure: (error) ->
      alert error
  })
  return


$.jade.renderSync = (fn, obj, failure) ->
  attrs = (o) ->
    r = " "
    $.each o, (i, n) ->
      r += i + "=\"" + n + "\""

    r

  document[fn] obj, attrs, ((val) ->
    val
  ), failure

$.pv3 = {}
$.pv3.growl = {}
$.pv3.growl.hide = ->
  $(".task-status").removeClass("active").css "display", "none"


###
@param type "success" or "error"
@param message HTML message (can be raw text)
###
$.pv3.growl.show = (type, message) ->
  $.pv3.growl.hide()
  $(".task-status." + type).css("display", "block").addClass "active"
  $(".status-content h2").html(type).next().html message

$.pv3.state = {}
$.pv3.state.get = (success, options) ->
  $.jsonrpc "user/get-state", {}, ((data) ->
    if data isnt `undefined`
      $.pv3.state.current = data
      success()  if success
      $(document).ready ->
        $(this).trigger "restore"

  ), ((error) ->
    console.error error
  ), options

$.pv3.state.restoreModule = ->
  module = (if (not $.pv3.state.current.modules.selected or $.pv3.state.current.modules.selected is "") then "home" else $.pv3.state.current.modules.selected)
  
  # TODO: fix!
  # for some reason module has an # appended?
  module = module.replace("#", "")
  window.history.pushState "", module, "/" + module
  $("#main-container").trigger "ajaxUnload"
  $.pv3.state.update "modules.selected", module
  $.ajax("/modules/" + module + "?ajax=1",{
    success: (data) ->
      $("#ajax-container").html data
      $(".selected").removeClass "selected"
      $("#spine-inner nav li a#nav-" + module).parent().addClass "selected"
      $(".ajax-spinner").hide()
      
      # restore panels
      modules = $.pv3.state.current.modules
      $.pv3.panel.show modules[modules.selected].panel.active.url, modules[modules.selected].panel.active.options  if modules[modules.selected] isnt `undefined` and modules[modules.selected].panel isnt `undefined` and modules[modules.selected].panel.active?
  })
  return

$.pv3.state.restore = ->
  $(document).ready ->
    if $.pv3.state.current is `undefined`
      $.pv3.state.get ->
        $.pv3.state.restoreModule $.pv3.state.current.modules  if $.pv3.state.current.modules isnt `undefined` and $.pv3.state.current.modules.selected isnt `undefined`



$.pv3.state.update = (stateName, stateValue) ->
  $.jsonrpc "user/update-state",
    name: stateName
    value: stateValue
  , ((result) ->
    $.pv3.state.current = result
  ), (error) ->
    console.error error


$.pv3.panel = {}
$.pv3.panel.show = (url, options) ->
  active = false
  options = options or {}
  
  # temporary work-around for absence of panel data
  try
    active = $.pv3.state.current.modules[$.pv3.state.current.modules.selected].panel.active
  catch _
    console.warn "$.pv3.state.current.modules.panel is still not being returned!"
  options.jsonrpcMethod = "view" + url  if options.jsonrpcMethod is `undefined`
  
  # TODO: refactor this at some point, as it's duplicated below
  # is this panel already open? then close it
  if active and active.options.tabid is options.tabid
    if options.temporary isnt `undefined`
      
      # find temporary panel tabs
      $(".sectional-tabs").find(".temporary-panel-tab").remove()
      $(".ajax-panel-content").empty()
    $(".standout-disabled").removeClass("standout-disabled").addClass "standout-tab"
    
    # restore the standout tab to be the first child of the <ul>
    $(".sectional-tabs").restoreStandoutElement()
    $.pv3.panel.hide()
    return
  if options.temporary is `undefined` and $(".sectional-tabs").find(".temporary-panel-tab").length
    $(".standout-disabled").removeClass("standout-disabled").addClass "standout-tab"
    
    # restore the standout tab to be the first child of the UL
    $(".sectional-tabs").restoreStandoutElement()
    
    # find temporary panel tabs
    $(".sectional-tabs").find(".temporary-panel-tab").remove()
    $(".ajax-panel-content").empty()
  
  # make the JSON-RPC call
  $.jsonrpc options.jsonrpcMethod, {}, (obj) ->
    $.jade.getTemplate url, (fn) ->
      $sectionalTabs = $(".sectional-tabs")
      $sectionPanel = $("#section-panel")
      
      # notify the server that the active tab has changed
      $.pv3.state.update "modules." + $.pv3.state.current.modules.selected + ".panel.active",
        url: url
        options: options

      
      # set active tab
      $sectionalTabs.find("li").removeClass("active").filter(".standout-tab").removeClass("standout-tab").addClass "standout-disabled"
      $sectionalTabs.find("#" + options.tabid).addClass "active"
      
      # set the active tab to be the first child of the UL
      $sectionalTabs.reorderActiveElement()
      $sectionPanel.removeClass().addClass options.panel_size
      $(".ajax-panel-content").html $.jade.renderSync(fn, obj, (err, file, line) ->
        $(".ajax-panel-content").html "Error in " + file + " at line " + line + ": " + err
      )
      
      # fix close handler
      $(".x-panel").unbind("click").on "click", (e) ->
        e.preventDefault()
        $(".standout-disabled").removeClass("standout-disabled").addClass "standout-tab"
        
        # restore the standout tab to be the first child of the UL
        $sectionalTabs.restoreStandoutElement()
        
        # find temporary panel tabs
        $(".sectional-tabs").find(".temporary-panel-tab").remove()
        $(".ajax-panel-content").empty()
        $.pv3.panel.hide()




$.pv3.panel.hide = ->
  $sectionPanel = $("#section-panel")
  if $sectionPanel.hasClass("hidden")
    $sectionPanel.removeClass "hidden"
    $(this).addClass "active"
  else
    $sectionPanel.addClass "hidden"
    $(".sectional-tabs .active").removeClass "active"
  
  # notify the server that the active tab has changed
  $.pv3.state.update "modules." + $.pv3.state.current.modules.selected + ".panel.active", null

$.fn.reorderActiveElement = ->
  @children(".active").detach().prependTo this

$.fn.restoreStandoutElement = ->
  @children(".standout-tab").detach().prependTo this