class API_User_UpdateState
	module.exports = @

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
		}
	}

	options: {
		"requireUserSession": true
	}

	run: (req) ->
		req.updateState(
			req.params.name
			, req.params.value
			, (state) ->
				return req.success(state)
			, (error) ->
				return req.error(error)
			, req.getUserId()
		)