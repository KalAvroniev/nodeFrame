// Generated by CoffeeScript 1.3.3

$.jsonrpc = function(method, params, success, failure, options) {
  var ajax;
  options = options || {};
  success = success || $.noop;
  failure = failure || function(errMsg, errCode) {
    console.error("Error " + errCode + ": " + errMsg);
  };
  ajax = {
    type: "POST",
    url: "/jsonrpc",
    processData: false,
    dataType: "json",
    data: JSON.stringify({
      jsonrpc: "2.0",
      method: method,
      params: params,
      id: 1
    }),
    success: function(result) {
      if (result.error !== undefined && result.error.message) {
        if (result.error.message.substr(0, 8) === "!logout:") {
          document.location = "/login";
        }
        return failure(result.error.message, result.error.code);
      }
      return success(result.result);
    },
    error: function(jqXHR, textStatus, errorThrown) {
      return failure(textStatus, 0);
    }
  };
  if (options.async !== undefined) {
    ajax.async = options.async;
  }
  return $.ajax(ajax);
};

$.jsonrpcSync = function(method, params, success, failure, options) {
  options = options || {};
  options.async = false;
  return $.jsonrpc(method, params, success, failure, options);
};

$.fn.serializeJSON = function() {
  var a, o;
  o = {};
  a = this.serializeArray();
  $.each(a, function() {
    if (o[this.name]) {
      if (!o[this.name].push) {
        o[this.name] = [o[this.name]];
      }
      o[this.name].push(this.value || "");
    } else {
      o[this.name] = this.value || "";
    }
  });
  return o;
};
