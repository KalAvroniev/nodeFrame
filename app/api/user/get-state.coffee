class exports.Controller

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
