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
		console.log(session)
		if not user_id
			# permission checking
			if session.user == undefined or session.user.user_id == undefined
				return req.error('No user ID. You may not have permission to access this.')
			user_id = session.user.user_id
		
		req.getState(
			(state) ->
				return req.success(state)
			, user_id
		);
		#return req.success(state)
		
		# cool
		#return req.success(session)
