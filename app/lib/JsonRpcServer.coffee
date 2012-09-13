fs = require('fs')
path_module = require('path')

class JsonRpcServer
	module.exports = @

	# error codes
	@PARSE_ERROR = -32700
	@INVALID_REQUEST = -32600
	@METHOD_NOT_FOUND = -32601
	@INVALID_PARAMS = -32602
	@INTERNAL_ERROR = -32603

	constructor: () ->
		@registeredMethods = {}

	registerMethods: (basePath = __dirname + '/../api', path = null) ->
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
			@registerMethod(path.substr(basePath.length + 1, path.length - 8 - basePath.length), path)

		# print
		if path == basePath
			console.log()

	getController: (path) ->
		controller = app.modules
		path = path_module.resolve(path)
		ext = path_module.extname(path)
		module = path_module.basename(path, ext)
		path = path_module.dirname(path)				
		folders = path.split(path_module.sep)
		start = folders.indexOf('api')
		if start >= 0
			for i in [start..folders.length - 1]
				controller = controller[folders[i]]
			return controller[module]
		else
			return false		

	registerMethod: (name, path) ->
		console.log("  JSON-RPC Method '" + name + "'")
		controller = @getController(path)
		@registeredMethods[name] = controller
		@flushCache(name)
		
	flushCache: (url) ->
		if app.config.flush? and (app.config.flush == 'all' or url in app.config.flush)
			method = new @registeredMethods[url]
			method.delDataFromCache(url)

	handleRequest: (req, res) ->
		return @handleCall(req.body, res, req)

	call: (method, params, callback) ->
		return @handleRawCall(
			{
				'jsonrpc': '2.0',
				'method': method,
				'params': params,
				'id': 1
			}
			, (data) ->
				res = JSON.parse(data)
				return callback(res.result, res.error)
		)

	handleRawCall: (call, callback, options = {}) ->
		# validate
		if call.id == undefined
			result = JsonRpcServer.Error(null, "No 'id' provided.", JsonRpcServer.INVALID_REQUEST)
		else if call.jsonrpc == undefined || call.jsonrpc != '2.0'
			result = JsonRpcServer.Error(call.id, "Only accepted JSON-RPC version is '2.0'"
				, JsonRpcServer.INVALID_REQUEST)
		else if call.method == undefined
			result = JsonRpcServer.Error(null, "No 'method' provided."
				, JsonRpcServer.INVALID_REQUEST)
		else if call.params == undefined
			result = JsonRpcServer.Error(null, "No 'params' provided."
				, JsonRpcServer.INVALID_REQUEST)
		else if (@registeredMethods)[call.method] == undefined
			result = JsonRpcServer.Error(null, "No such method '" + call.method + "'."
				, JsonRpcServer.METHOD_NOT_FOUND)

		if result
			return callback(JSON.stringify(result))

		# build the request
		req = new app.modules.lib.JsonRpcRequest(
			call
			, (result, error = null) =>
				if error
					r = JsonRpcServer.Error(call.id, error, JsonRpcServer.INTERNAL_ERROR)
				else
					r = JsonRpcServer.Success(call.id, result)

				return callback(JSON.stringify(r))
		)
		req.options = options

		# validate
		obj = new @registeredMethods[call.method]
		req.validate(
			obj
			, () ->
				# execute the method
				obj.run(req, call.method)
		)

	handleCall: (call, res, req) ->
		return @handleRawCall(
			call
			, (raw_result) ->
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
