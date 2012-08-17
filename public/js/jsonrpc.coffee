# install JSON-RPC client
$.jsonrpc = (method, params, success, failure, options) ->
  options = options or {}
  success = success or $.noop
  failure = failure or (errMsg, errCode) ->
    console.error "Error " + errCode + ": " + errMsg
    return

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

$.jsonrpcSync = (method, params, success, failure, options) ->
  options = options or {}
  options.async = false
  $.jsonrpc method, params, success, failure, options

$.fn.serializeJSON = ->
  o = {}
  a = @serializeArray()
  $.each a, ->
    if o[@name]
      o[@name] = [o[@name]]  unless o[@name].push
      o[@name].push @value or ""
    else
      o[@name] = @value or ""

  o