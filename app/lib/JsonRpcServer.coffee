fs = require('fs')

class exports.JsonRpcServer

	# error codes
	@PARSE_ERROR = -32700
	@INVALID_REQUEST = -32600
	@METHOD_NOT_FOUND = -32601
	@INVALID_PARAMS = -32602
	@INTERNAL_ERROR = -32603
	
	constructor: () ->
		@registeredMethods = {}
		
	registerMethods: (path = 'api') ->
		if path == 'api'
			console.log("Registering JSON-RPC methods...")
		
		# read the directory
		try
			files = fs.readdirSync(path)
			files.forEach((file) =>
				if file.substr(0, 1) != '.'
					@registerMethods(path + '/' + file)
			)
		catch e
			console.error(path.substr(4, path.length - 11))
			@registerMethod(path.substr(4, path.length - 11), require('../' + path).Controller)
			
		# print
		if path == 'api'
			console.log(@registeredMethods)
		
	registerMethod: (name, func) ->
		@registeredMethods[name] = func
	
	handleRequest: (req, res) ->
		data = ''
		req.setEncoding('utf8')
		req.on 'data', (chunk) ->
			data += chunk
		req.on 'end', () =>
			console.log(JSON.parse(data))
			@handleCall(JSON.parse(data), res)
			
	call: (method, params, callback) ->
		return @handleRawCall(
			{
				'jsonrpc': '2.0',
				'method': method,
				'params': params,
				'id': 1
			},
			(data) ->
				res = JSON.parse(data)
				return callback(res.result, res.error)
		)
			
	handleRawCall: (call, callback) ->
		# validate
		if call.id == undefined
			result = JsonRpcServer.Error(null, "No 'id' provided.", JsonRpcServer.INVALID_REQUEST)
		else if call.jsonrpc == undefined || call.jsonrpc != '2.0'
			result = JsonRpcServer.Error(call.id, "Only accepted JSON-RPC version is '2.0'",
				JsonRpcServer.INVALID_REQUEST)
		else if call.method == undefined
			result = JsonRpcServer.Error(null, "No 'method' provided.",
				JsonRpcServer.INVALID_REQUEST)
		else if call.params == undefined
			result = JsonRpcServer.Error(null, "No 'params' provided.",
				JsonRpcServer.INVALID_REQUEST)
		else if (@registeredMethods)[call.method] == undefined
			result = JsonRpcServer.Error(null, "No such method '" + call.method + "'.",
				JsonRpcServer.METHOD_NOT_FOUND)
		
		if result
			return callback(JSON.stringify(result))

		# execute the method
		obj = new @registeredMethods[call.method]
		console.log(new @registeredMethods[call.method])
		obj.run(call.params, (result, error = null) =>
			if error
				r = JsonRpcServer.Error(call.id, error, JsonRpcServer.INTERNAL_ERROR)
			else
				r = JsonRpcServer.Success(call.id, result)
			
			return callback(JSON.stringify(r))
		)
	
	handleCall: (call, res) ->
		return @handleRawCall(
			call,
			(raw_result) ->
				res.write(raw_result)
				res.end()
		)

	@Success: (id, result) ->
		return {
			'jsonrpc': '2.0',
			'result': result,
			'id': id
		}
		
	@Error: (id, errorMsg, errorCode = JsonRpcServer.INTERNAL_ERROR) ->
		return {
			'jsonrpc': '2.0',
			'error': {
				'message': errorMsg,
				'code': errorCode
			},
			'id': id
		}
