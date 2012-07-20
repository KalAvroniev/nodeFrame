// install JSON-RPC client
$.jsonrpc = function (method, params, success, failure) {
	if(failure == undefined) {
		failure = function (errMsg, errCode) {
			alert("Error " + errCode + ": " + errMsg);
		}
	}
	
	$.ajax({
		type: 'POST',
		url: '/jsonrpc',
		processData: false,
		data: JSON.stringify({
			'jsonrpc': '2.0',
			'method': method,
			'params': params,
			'id': 1
		}),
		success: function (result) {
			return success(result.result);
		},
		dataType: 'json'
	});
}

$.ajaxPanel = function (url, success, failure) {
	if(failure == undefined) {
		failure = function (errMsg, errCode) {
			alert("Error " + errCode + ": " + errMsg);
		}
	}
	
	$.ajax({
		type: 'GET',
		url: url,
		processData: false,
		success: success
	});
}

$.jade = {};
$.jade.getTemplate = function (url, success, options) {
	// is it already loaded?
	var fn = 'views_' + url.replace(/\//g, '_');
	if(document[fn] != undefined)
		return success(fn);
	
	// we need to load it
	$.ajax({
		url: url + ".jade",
		dataType: "script",
		success: function () {
			var fn = 'views_' + url.replace(/\//g, '_');
			console.log(fn);
			//document[fn] = fn;
			success(fn);
		},
		failure: function (error) {
			alert(error);
		}
	});
}
$.jade.renderSync = function (fn, obj, failure) {
	var attrs = function (o) {
		var r = " ";
		$.each(o, function (i, n) {
			r += i + '="' + n + '"';
		});
		return r;
	}
	
	return document[fn](
		obj,
		attrs,
		function (val) { return val; },
		failure
	);
}

$.restorePanel = function (url, options) {
	if(options == undefined) {
		options = {
			'jsonrpcMethod': url.replace(/^\/modules\//, '')
		};
	}
	console.log(options);
	
	// make the JSON-RPC call
	$.jsonrpc(
		options.jsonrpcMethod,
		{},
		function (obj) {
			console.log(obj);
			console.log(url + ".jade");
			
			$.jade.getTemplate(function (fn) {
				$('#section-panel').removeClass('hidden');
				$('.ajax-panel-content').html($.jade.renderSync(fn, obj, function (err, file, line) {
					$('.ajax-panel-content').html("Error in " + file + " at line " + line + ": " + err);
				}));
			});
		}
	);
}

$.pv3 = {};
$.pv3.restoreState = function () {
	console.log("restore state");
}
