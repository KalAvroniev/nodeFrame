class JsonRpcRequest
	module.exports = @

	constructor: (service, method, params, @callback) ->
		@url = JsonRpcRequest.getServiceUrl(service)
		if @url?
			@request = new app.modules.lib.JsonRpc.type.External(@url, method, params, @callback)
		else
			@request = new app.modules.lib.JsonRpc.type.Internal(@url, method, params, @callback)
		
	# Validate parameters
	validate: (obj, success) ->
		@request.validate(obj, success)

	send: (error, result) ->
		@request.send(error, result)
		
	@getServiceUrl: (service) ->
		if service?
			return app.config.apis[service]
		else
			return service