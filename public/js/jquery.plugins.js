// install JSON-RPC client
$.jsonrpc = function (method, params, success, failure) {
	if(failure == undefined) {
		failure = function (errMsg, errCode) {
			console.error("Error " + errCode + ": " + errMsg);
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
			if(result.error != undefined && result.error.message)
				return failure(result.error.message, result.error.code);
			return success(result.result);
		},
		dataType: 'json',
		error: function (jqXHR, textStatus, errorThrown) {
			return failure(textStatus, 0);
		}
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

$.pv3 = {};

$.pv3.state = {};
$.pv3.state.get = function (success) {
	$.jsonrpc(
		'user/get-state',
		{},
		function (data) {
			if(data != undefined) {
				$.pv3.state.current = data;
				if(success)
					success();
			}
		},
		function (error) {
			console.error(error);
		}
	);
}
$.pv3.state.restoreModule = function (modules) {
	var module = (!modules.selected || modules.selected == '') ? 'home' : modules.selected;
	window.history.pushState('', module, "/" + module);
	$("#main-container").trigger("ajaxUnload");
	$.pv3.state.update('modules.selected', module);
	$.ajax('/modules/' + module + '?ajax=1', {
		'success': function (data) {
			$('#ajax-container').html(data);
			$('.selected').removeClass("selected");
			$('#spine-inner nav li a#nav-' + module).parent().addClass("selected");
			$(".ajax-spinner").hide();
			
			// restore panels
			if(modules[modules.selected].panel != '')
				$.pv3.panel.show(modules[modules.selected].panel);
		}
	});
}
$.pv3.state.restore = function () {
	$(document).ready(function () {
		if($.pv3.state.current == undefined) {
			$.pv3.state.get(function () {
				if($.pv3.state.current.modules != undefined && $.pv3.state.current.modules.selected != undefined)
					$.pv3.state.restoreModule($.pv3.state.current.modules);
			});
		}
	});
}
$.pv3.state.update = function (stateName, stateValue) {
	$.jsonrpc(
		'user/update-state',
		{ 'name': stateName, 'value': stateValue },
		function (result) {
			$.pv3.state.current = result;
		},
		function (error) {
			console.error(error);
		}
	);
}

$.pv3.panel = {};
$.pv3.panel.show = function (url, options) {
	if(options == undefined)
		options = {};
	if(options.jsonrpcMethod == undefined)
		options.jsonrpcMethod = 'view' + url;
	
	// make the JSON-RPC call
	$.jsonrpc(
		options.jsonrpcMethod,
		{},
		function (obj) {
			$.jade.getTemplate(url, function (fn) {
				// nofify the server that the active tab has changed
				console.log($.pv3.state.current);
				$.pv3.state.update('modules.' + $.pv3.state.current.modules.selected + '.panel', url);
				
				// set active tab
				$('.sectional-tabs li').removeClass('active');
				$('.sectional-tabs #' + options.tabid).addClass('active');
				
				$('#section-panel').removeClass('hidden');
				$('.ajax-panel-content').html($.jade.renderSync(fn, obj, function (err, file, line) {
					$('.ajax-panel-content').html("Error in " + file + " at line " + line + ": " + err);
				}));
					
				// fix close handler
				$("#import-export, .x-panel").unbind('click');
				$("#import-export, .x-panel").click(function () {
					return $.pv3.panel.hide();
				});
			});
		}
	);
}
$.pv3.panel.hide = function () {
	if ( $("#section-panel").hasClass("hidden") ) {
		$("#section-panel").removeClass("hidden");
		$( this ).addClass("active");
	} else {
		$("#section-panel").addClass("hidden")
		$(".sectional-tabs .active").removeClass("active");
	}
	
	// notify the server that the active tab has changed
	$.pv3.state.update('modules.' + $.pv3.state.current.modules.selected + '.panel', null);
}
