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
			
			$.ajax({
				url: url + ".jade",
				dataType: "script",
				success: function () {
					var attrs = function (o) {
						var r = " ";
						$.each(o, function (i, n) {
							r += i + '="' + n + '"';
						});
						console.log(r);
						return r;
					}
					
					var fn = 'views' + url.replace(/\//g, '_');
					$('#section-panel').removeClass('hidden');
					var compiler = new jade.Compiler({});
					$('.ajax-panel-content').html(document[fn](
						obj,
						attrs,
						function (val) { return val; },
						function (err, file, line) {
							$('.ajax-panel-content').html("Error in " + file + " at line " + line + ": " + err);
						}
					));
				},
				failure: function (error) {
					alert(error);
				}
			});
		}
	);
}
