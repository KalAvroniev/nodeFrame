class JsonRpcRequest
	module.exports = @

	constructor: (service = null, method = null, params = [], @request_ids = {}, @callback) ->
		if not method?
			@bulk_requests = {} 
			
		@url = JsonRpcRequest.getServiceUrl(service)
		if @url?
			@request = new app.modules.lib.JsonRpc.type.External(@url, method, params, @callback)
		else
			@request = new app.modules.lib.JsonRpc.type.Internal(@url, method, params, @callback)
		#check for duplicate calls
		if not @request_ids.hasOwnProperty(@request.call.id)
			@request_ids[@request.call.id] = @
		else
			@request = undefined
		
	# Validate parameters
	validate: (obj, success) ->
		@request.validate(obj, success)
		
	add: (service, method, params, callback) ->
		batch = if service? then service else 'local'
		if not @bulk_requests[batch]?
			@bulk_requests[batch] = new JsonRpcRequest(service, 'bulk', [], @request_ids, @bulkResponse) 
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
			return app.config.apis[service]
		else
			return service
			
	getRequestById: (id) ->
		return @request_ids[id]
		
	bulkResponse: (err, id, res) =>
		if res
			@sendRespose(err, id, res)
		else
			@retry(err, id, res)			
			
	getChildrenRequests: (bulk_id) ->
		children = []
		bulk = @getRequestById(bulk_id)
		bulk.request.call.params.forEach((call) =>
			children.push(@getRequestById(call.id))
		)
		return children
		
	retry: (err, id, res) ->
		if res != 'Stop'
			call = @getRequestById(id)
			call.send(err, res)
				
	sendRespose: (err, id, res) ->
		if err
			@getChildrenRequests(id).forEach((child) ->
				child.request.callback(err, child.request.call.id) if child.request.callback?
			)
		else
			@getChildrenRequests(id).forEach((child) =>
				response = @getResponse(child.request.call.id, res)
				try
					child.request.checkForError(response)
					child.request.callback(null, child.request.call.id, response) if child.request.callback?
				catch err
					child.request.callback(err, child.request.call.id) if child.request.callback?
			)
			
	getResponse: (id, res) ->
		res = JSON.parse(res)
		for response in res.result
			if response.id == id
				return JSON.stringify(response) 
			