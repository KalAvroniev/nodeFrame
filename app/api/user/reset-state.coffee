class API_User_ResetState
	module.exports = @

	validate: {
	}

	run: (req) ->
		req.resetState(
			(state) ->
				return req.success(state)
			, (error) ->
				return req.error(error)
			, req.getUserId()
		)
