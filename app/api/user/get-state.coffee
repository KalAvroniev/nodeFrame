class API_User_GetState extends app.modules.lib.APIController
	module.exports = @

	constructor: () ->
		super
		options =
			"requireUserSession": true

	render: (req, cb) ->
		req.getState(
			(state) ->
				cb(null,state)
			, req.getUserId()
		)