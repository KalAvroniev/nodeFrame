class API_User_ResetState extends app.modules.lib.APIController
	module.exports = @

	render: (req, cb) ->
		req.resetState(
			(state) ->
				cb(null,state)
			, (error) ->
				cb(error)
			, req.getUserId()
		)