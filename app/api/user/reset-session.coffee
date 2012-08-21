class API_User_ResetSession
	module.exports = @

	validate: {
	}

	run: (req) ->
		req.resetSession(() ->
			return req.success(true)
		)
