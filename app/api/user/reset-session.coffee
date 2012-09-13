class API_User_ResetSession extends app.modules.lib.APIController
	module.exports = @

	render: (req, cb) ->
		req.resetSession(() ->
			cb(null,true)
		)