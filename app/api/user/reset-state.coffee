class exports.Controller

	validate: {
		"user_id": {
			"description": "An optional user ID.",
			"type": "string"
		}
	}
	
	run: (req) ->
		user_id = req.params.user_id
		session = req.getSession()
		
		if not user_id
			# permission checking
			if session.user == undefined or session.user.user_id == undefined
				return req.error('No user ID. You may not have permission to access this.')
			user_id = session.user.user_id
		
		req.resetState(
			(state) ->
				return req.success(state)
			, (error) ->
				return req.error(error)
			, user_id
		);
