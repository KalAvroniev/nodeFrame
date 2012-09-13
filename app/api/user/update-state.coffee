class API_User_UpdateState extends app.modules.lib.APIController
	module.exports = @

	constructor: () ->
		super
		validate =
			"name":
				"description": "State key.",
				"type": "string",
				"required": true
			"value":
				"description": "New value for state key.",
				"type": "any",
				"required": true
	options = 
		"requireUserSession": true

	render: (req, cb) ->
		req.updateState(
			req.params.name
			, req.params.value
			, (state) ->
				cb(null,state)
			, (error) ->
				cb(error)
			, req.getUserId()
		)