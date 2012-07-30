class exports.Controller

	validate: {
	}
	
	run: (req) ->
		req.resetSession(() ->
			return req.success(true)
		)
