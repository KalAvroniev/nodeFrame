fs = require('fs')
path_module = require('path')
async = require('async')

class JsonRpcServer
	module.exports = @

	# error codes
	@PARSE_ERROR = -32700
	@INVALID_REQUEST = -32600
	@METHOD_NOT_FOUND = -32601
	@INVALID_PARAMS = -32602
	@INTERNAL_ERROR = -32603

	# Handles cache flushing based on configuration/modified apis
	flushingCache: (basePath = __dirname + '/../api', path = null, queue = null) ->
		if path == null
			path = basePath

		if queue == null
			queue = async.queue((path, callback) =>
					fs.stat(path, (err, stat) =>
						if not err
							if stat.isDirectory()
								@flushingCache(basePath, path, queue)
							else
								@flushCacheSync(path.substr(basePath.length + 1, path.length - 8 - basePath.length))
					)
					callback()
				, 10
			)
		# read the directory
		fs.readdir(path, (err, files) ->
			if not err
				files.forEach((file) ->
					if file.substr(0, 1) != '.'
						queue.push(path + '/' + file, (err) ->
							if err
								throw app.logger(err, @, 'fatal')
						)
				)
		)

	# Find and return a controller basd on path
	getControllerSync: (path) ->
		try
			controller = app.modules
			path = path_module.resolve('api/' + path)
			ext = path_module.extname(path)
			module = path_module.basename(path, ext)
			path = path_module.dirname(path)				
			folders = path.split(path_module.sep)
			start = folders.indexOf('api')
			if start >= 0
				for i in [start..folders.length - 1]
					controller = controller[folders[i]]
				return controller[module]
		catch err
			throw app.logger(err, 'fatal')
		
	# Delete api cache
	flushCacheSync: (url) ->
		if app.config.flush? and (app.config.flush == 'all' or url in app.config.flush)
			try
				method = new (@getControllerSync(url))
				method.delDataFromCache(url)
			catch err			
				#do nothing

	# The middleware that handles all api urls
	handleRequest: (req, res) ->
		return @handleRawCall(
			req.body
			, (raw_result) ->
				#view can go here
				res.write(raw_result)
				res.end()
			, {
				'res': res,
				'req': req
			}
			)

	# Jsonrpc call gets validated and handled
	handleRawCall: (request, callback, options = {}) ->
		# validate
		try
			controller = @getControllerSync(request.method)
		catch err
			controller = undefined			
		if request.id == undefined
			result = JsonRpcServer.Error(null, "No 'id' provided.", JsonRpcServer.INVALID_REQUEST)
		else if request.jsonrpc == undefined || request.jsonrpc != '2.0'
			result = JsonRpcServer.Error(request.id, "Only accepted JSON-RPC version is '2.0'"
				, JsonRpcServer.INVALID_REQUEST)
		else if request.method == undefined
			result = JsonRpcServer.Error(null, "No 'method' provided."
				, JsonRpcServer.INVALID_REQUEST)
		else if request.params == undefined
			result = JsonRpcServer.Error(null, "No 'params' provided."
				, JsonRpcServer.INVALID_REQUEST)
		else if controller == undefined
			result = JsonRpcServer.Error(null, "No such method '" + request.method + "'."
				, JsonRpcServer.METHOD_NOT_FOUND)

		if result
			return callback(JSON.stringify(result))

		# build the request
		req = new app.modules.lib.JsonRpc.Request(null, request.method, request.params, (error, result) ->
			if error
				r = JsonRpcServer.Error(request.id, error, JsonRpcServer.INTERNAL_ERROR)
			else
				r = JsonRpcServer.Success(request.id, result)
			return callback(JSON.stringify(r))
		)
		req.options = options

		# validate
		obj = new controller()
		req.validate(obj, () ->
			# execute the method
			obj.run(req, request.method)
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
