// Generated by CoffeeScript 1.3.3

$.jade = {};

$.jade.getTemplate = function(url, success, options) {
  var fn, fnRaw;
  fnRaw = url.replace(/[\/-]/g, "_");
  fn = void 0;
  if (fnRaw.charAt(0) === "_") {
    fnRaw = fnRaw.substr(1);
  }
  fn = "views_modules_" + fnRaw;
  if (document[fn] !== undefined) {
    return success(fn);
  }
  $.ajax({
    url: url + ".jade",
    dataType: "script",
    success: function() {
      fnRaw = url.replace(/[\/-]/g, "_");
      fn = void 0;
      if (fnRaw.charAt(0) === "_") {
        fnRaw = fnRaw.substr(1);
      }
      fn = "views_modules_" + fnRaw;
      success(fn);
    },
    failure: function(error) {
      alert(error);
    }
  });
};

$.jade.renderSync = function(fn, obj, failure) {
  var attrs;
  attrs = function(o) {
    var r;
    r = " ";
    $.each(o, function(i, n) {
      r += i + "=\"" + n + "\"";
    });
    return r;
  };
  return document[fn](obj, attrs, (function(val) {
    return val;
  }), failure);
};
