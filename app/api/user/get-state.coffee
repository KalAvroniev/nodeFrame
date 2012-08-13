class API_User_GetState
	module.exports = @

	validate: {
	}
	
	options: {
		"requireUserSession": true
	}
	
	run: (req) ->
		req.getState(
			(state) ->
				return req.success(state)
			, req.getUserId()
		);
