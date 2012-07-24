class exports.Controller

	validate: {
		"name": {
			"description": "State key.",
			"type": "string",
			"required": true
		},
		"value": {
			"description": "New value for state key.",
			"type": "any",
			"required": true
		},
		"user_id": {
			"description": "An optional user ID.",
			"type": "string"
		}
	}
	
	run: (req) ->
		user_id = req.params.user_id
		session = req.getSession()
		console.log(session);
		if not user_id
			# permission checking
			if session.user == undefined or session.user.user_id == undefined
				return req.error('No user ID. You may not have permission to access this.')
			user_id = session.user.user_id
		
		req.updateState(
			req.params.name,
			{ "value": req.params.value },
			() ->
				return req.success()
			, (error) ->
				return req.error(error)
			, user_id
		);
