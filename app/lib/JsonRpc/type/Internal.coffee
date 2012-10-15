class JsonRpcInternalRequest extends app.modules.lib.JsonRpc.Abstract
	module.exports = @

	constructor: (@url, method, params, @callback) ->
		@path = null
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
		@callback(error, result)