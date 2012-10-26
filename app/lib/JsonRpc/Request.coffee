URL = require('url')

class JsonRpcRequest
	module.exports = @

	constructor: (service = null, method = null, params = [], @request_ids = {}, @callback) ->
		if not method?
			@bulk_requests = {} 
			
		@url = JsonRpcRequest.getServiceUrl(service)
		if @url?
			@request = new app.modules.lib.JsonRpc.Type.External(service, @url, method, params, @callback)	
		else
			@request = new app.modules.lib.JsonRpc.Type.Internal(@url, method, params, @callback)
		#check for duplicate calls
		if not @request_ids.hasOwnProperty(@request.call.id)
			@request_ids[@request.call.id] = @
		else
			@request = undefined
		
	# Validate parameters
	validate: (obj, success) ->
		@request.validate(obj, success)
		
	add: (service, method, params, callback, retries = 3) ->
		batch = if service? then service else 'local'
		if not @bulk_requests[batch]?
			@bulk_requests[batch] = new JsonRpcRequest(service, 'bulk', [], @request_ids, @bulkResponse) 
			if retries != 3
				@bulk_requests[batch].request.setRetries(retries)
				
		single = new JsonRpcRequest(service, method, params, @request_ids, callback)
		#check for duplicate calls
		if single.request?
			@bulk_requests[batch].request.call.params.push(single.request.call)

	send: (error, result) ->
		if @bulk_requests? and Object.keys(@bulk_requests).length > 0
			Object.keys(@bulk_requests).forEach((service) =>
				@bulk_requests[service].request.send(error, result)
			)
		else
			@request.send(error, result)
		
	@getServiceUrl: (service) ->
		if service?
			if app.config.apis[service]?
				return app.config.apis[service] 
			else 
				throw app.logger(new app.error('System does not know about ' + service + 'service', 'error'))
		else
			return service
			
	getRequestById: (id) ->
		return @request_ids[id]
		
	bulkResponse: (err, id, service, res) =>
		if res
			@sendRespose(err, id, service, res)
		else
			@retry(err, id, res)			
			
	getChildrenRequests: (bulk_id, cb) ->
		children = []
		bulk = @getRequestById(bulk_id)
		counter = bulk.request.call.params.length
		bulk.request.call.params.forEach((call) =>
			counter--
			children.push(@getRequestById(call.id))
			if counter <= 0
				cb(children)
		)
		
	retry: (err, id, res) ->
		if res != 'Stop'
			call = @getRequestById(id)
			call.send(err, res)
				
	sendRespose: (err, id, service, res) ->
		if err
			@getChildrenRequests(id, (children) ->
				children.forEach((child) ->
					child.request.callback(err, child.request.call.id) if child.request.callback?
				)
			)
		else
			@getChildrenRequests(id, (children) =>
				children.forEach((child) =>
					response = @getResponse(child.request.call.id, res)
					try
						child.request.checkForError(response)
						child.request.callback(null, child.request.call.id, response) if child.request.callback?
						@storeLocalCache(service, child.request, JSON.parse(response).result)
					catch err
						child.request.callback(err, child.request.call.id) if child.request.callback?
				)
			)
			
	getResponse: (id, res) ->
		res = JSON.parse(res)
		for response in res.result
			if response.id == id
				return JSON.stringify(response) 
				
	storeLocalCache: (service, request, data) ->
		if data? and data.cache
			if service? and app.config.namespaces[service]?
				tmp = JsonRpcRequest.getServiceUrl(service).split(':')
				controller = URL.format(
					hostname: tmp[0] + request.path + '/' + request.call.method
				).replace('//', '')			
				namespace = app.config.namespaces[service][app.options.cache.CS.hashSync(controller)]

				if namespace?
					#look for cache
					full_url = URL.format(
						hostname: tmp[0] + request.path + '/' + request.call.method
						query: request.call.params
					).replace('//', '')	
					index = app.options.cache.hashTagSync(full_url, namespace)
					app.options.cache.write(index, JSON.stringify(data), data.expire, (err, data, change) =>
						if err
							app.logger(new app.error("Data cache could not be saved: " + err, @, 'warn'))
						else
							app.logger("Local data cache saved.")
					)