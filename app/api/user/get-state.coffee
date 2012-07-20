class exports.Controller

	validate: {
		"user_id": {
			"description": "An optional user ID.",
			"type": "string"
		}
	}
	
	run: (req) ->
		req.getState(
			(state) ->
				return req.success(state)
			, req.params.user_id
		);
		#return req.success(state)
		
		# permission checking
		#if session.user == undefined or session.user.user_id == undefined
		#	return req.error('No user ID. You may not have permission to access this.')
		
		# cool
		#return req.success(session)
