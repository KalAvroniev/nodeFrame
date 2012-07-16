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

$.restorePanel = function (url, obj) {
	console.log(url + ".jade");
	$.ajaxPanel(
		url + ".jade",
		function (data) {
			// compile
			eval(data);
			document.fn = anonymous;
			$('#section-panel').removeClass('hidden');
			$('#panel-content').html(anonymous(obj, obj,
				function (val) { return val; },
				function (err, file, line) {
					$('#panel-content').html("Error in " + file + " at line " + line);
				}
			));
		},
		function (error) {
			alert(error);
		}
	);
}
