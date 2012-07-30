fs = require('fs')

class exports.JsonRpcRequest

	constructor: (call, @callback) ->
		@version = call.jsonrpc
		@method = call.method
		@params = call.params
		@id = call.id

	validate: (definition, success) ->
		for field, def of definition
			# is the field required
			if def.required == undefined or not def.required
				# if it doesnt exist but we do have a default value to fill in
				if @params[field] == undefined and def.default != undefined
					@params[field] = def.default
			else
				if @params[field] == undefined
					return @error("Parameter '" + field + "' is required.")
		
		# run success handler
		success()
		
	success: (result) ->
		@callback(result)
		
	error: (message, code = -32603) ->
		@callback(null, message)
		
	logout: (message) ->
		@callback(null, "!logout:" + message)
	
	getSession: () ->
		return @options.req.session
	
	getSessionId: () ->
		return @options.req.sessionID
	
	getCookies: () ->
		return @options.req.cookies
		
	resetSession: (cb) ->
		if not @options.req.sessionID
			return cb()
		if not @options.req.cookies
			return cb()
		
		@options.req.sessionID = null
		@options.req.session.destroy(() ->
			return cb()
		)
	
	getState: (callback, userId) ->
		if(userId == undefined)
			return callback(null)
		else
			@options.application.states.get(
				userId,
				(state) ->
					return callback(state)
			)
	
	updateState: (name, value, success, error, userId) ->
		if(userId == undefined)
			return error("No user ID.")
		else
			@options.application.states.update(
				userId,
				name,
				value,
				(state) ->
					return success(state)
			)
	
	resetState: (success, error, userId) ->
		if(userId == undefined)
			return error("No user ID.")
		else
			@options.application.states.reset(
				userId,
				(state) ->
					return success(state)
			)

class exports.JsonRpcServer

	# error codes
	@PARSE_ERROR = -32700
	@INVALID_REQUEST = -32600
	@METHOD_NOT_FOUND = -32601
	@INVALID_PARAMS = -32602
	@INTERNAL_ERROR = -32603
	
	constructor: (@app = false) ->
		@registeredMethods = {}

	registerMethods: (basePath = 'api', path = null) ->
		if path == null
			path = basePath
		if path == basePath
			console.log("Registering JSON-RPC methods...")
		
		# read the directory
		try
			files = fs.readdirSync(path)
			files.forEach((file) =>
				if file.substr(0, 1) != '.'
					@registerMethods(basePath, path + '/' + file)
			)
		catch e
			@registerMethod(path.substr(basePath.length + 1, path.length - 8 - basePath.length), require('../' + path).Controller)
			
		# print
		if path == basePath
			console.log()
		
	registerMethod: (name, func) ->
		console.log("  JSON-RPC Method '" + name + "'")
		@registeredMethods[name] = func
	
	handleRequest: (req, res) ->
		data = ''
		req.setEncoding('utf8')
		req.on 'data', (chunk) ->
			data += chunk
		req.on 'end', () =>
			console.log(JSON.parse(data))
			@handleCall(JSON.parse(data), res, req)
			
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
			
	handleRawCall: (call, callback, options = {}) ->
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
			
		# build the request
		req = new exports.JsonRpcRequest(
			call,
			(result, error = null) =>
				if error
					r = JsonRpcServer.Error(call.id, error, JsonRpcServer.INTERNAL_ERROR)
				else
					r = JsonRpcServer.Success(call.id, result)
				
				return callback(JSON.stringify(r))
		)
		req.options = options
		req.options.application = @app
		
		# validate
		obj = new @registeredMethods[call.method]
		req.validate(
			obj.validate,
			() ->
				# execute the method
				obj.run(req)
		)
	
	handleCall: (call, res, req) ->
		return @handleRawCall(
			call,
			(raw_result) ->
				res.write(raw_result)
				res.end()
			, {
				'res': res,
				'req': req
			}
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
