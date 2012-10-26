class JsonRpcInternalRequest extends app.modules.lib.JsonRpc.Abstract
	module.exports = @

	constructor: (@url, method, params, @callback) ->
		@path = null
		@cache = false
		super

	# Validate parameters
	validate: (obj, success) ->
		for field, def of obj.validate
			# is the field required
			if def.required == undefined or not def.required
				# if it doesnt exist but we do have a default value to fill in
				if @call.params[field] == undefined and def.default != undefined
					@call.params[field] = def.default
					
			else
				if @call.params[field] == undefined
					return @send("Parameter '" + field + "' is required.")

		super

	send: (error, result) ->
		return if not super?
		if error? or result?
			@callback(error, @call.id, null, result)
		else
			if @call.method == 'bulk'
				app.jsonRpcServer.handleBulkCall(@call, {}, (response) =>
					try 
						@checkForError(response)
						@callback(null, @call.id, null, response)
					catch err
						@callback(err, @call.id)
				)
			else
				app.jsonRpcServer.handleRawCall(@call, {}, (response) =>
					try 
						@checkForError(response)
						@callback(null, @call.id, null, response)
					catch err
						@callback(err, @call.id)
				)
				
		