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
	var fnRaw = url.replace(/[\/-]/g, '_');
	if(fnRaw.charAt(0) == '_')
		fnRaw = fnRaw.substr(1);
	var fn = 'views_' + fnRaw;
	if(document[fn] != undefined)
		return success(fn);
	
	// we need to load it
	$.ajax({
		url: url + ".jade",
		dataType: "script",
		success: function () {
			var fnRaw = url.replace(/[\/-]/g, '_');
			if(fnRaw.charAt(0) == '_')
				fnRaw = fnRaw.substr(1);
			var fn = 'views_' + fnRaw;
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
	if(options == undefined)
		options = {};
	if(options.jsonrpcMethod == undefined)
		options.jsonrpcMethod = url.replace(/^\/modules\//, '');
	
	// make the JSON-RPC call
	$.jsonrpc(
		options.jsonrpcMethod,
		{},
		function (obj) {
			console.log(obj);
			console.log(url + ".jade");
			
			$.jade.getTemplate(url, function (fn) {
				// set active tab
				$('.sectional-tabs li').removeClass('active');
				$('.sectional-tabs #' + options.tabid).addClass('active');
				
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
	$(document).ready(function () {
		$.jsonrpc(
			'user/get-state',
			{},
			function (data) {
				if(data != undefined)
					navigate(data.module);
			},
			function (error) {
				console.error(error);
			}
		);
	});
}
$.pv3.updateState = function (stateName, stateValue) {
	$.jsonrpc(
		'user/update-state',
		{ 'name': stateName, 'value': stateValue },
		function (result) {
			// do nothing
		},
		function (error) {
			console.error(error);
		}
	);
}
