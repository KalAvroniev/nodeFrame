class exports.Controller

	validate: {
	}
	
	run: (req) ->
		req.resetState(
			(state) ->
				return req.success(state)
			, (error) ->
				return req.error(error)
			, req.getUserId()
		);
