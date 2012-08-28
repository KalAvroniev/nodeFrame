class JsonRpcRequest
	module.exports = @

	constructor: (call, @callback) ->
		@version = call.jsonrpc
		@method = call.method
		@params = call.params
		@id = call.id

	validate: (obj, success) ->
		for field, def of obj.validate
			# is the field required
			if def.required == undefined or not def.required
				# if it doesnt exist but we do have a default value to fill in
				if @params[field] == undefined and def.default != undefined
					@params[field] = def.default
					
			else
				if @params[field] == undefined
					return @error("Parameter '" + field + "' is required.")

		### options 
			if obj.options
				if obj.options.requireUserSession
					if not @validateUserSession()
						return
		###
		# run success handler
		success()

	validateUserSession: () ->
		session = @getSession()
		if not session or not session.user or not session.user.user_id
			@logout()
			return false
		return true

	success: (result) ->
		@callback(result)

	error: (message, code = -32603) ->
		@callback(null, message)

	logout: (message = '') ->
		@callback(null, "!logout:" + message)

	getSession: () ->
		return @options.req.session

	getSessionId: () ->
		return @options.req.sessionID

	getUserId: () ->
		return @options.req.session.user.user_id

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
			app.states.get(
				userId
				, (state) ->
					return callback(state)
			)

	updateState: (name, value, success, error, userId) ->
		if(userId == undefined)
			return error("No user ID.")
		else
			app.states.update(
				userId
				, name
				, value
				, (state) ->
					return success(state)
			)

	resetState: (success, error, userId) ->
		if(userId == undefined)
			return error("No user ID.")
		else
			app.states.reset(
				userId
				, (state) ->
					return success(state)
			)
