APIController = require(app.config.appDir + '/lib/APIController.coffee')

class API_User_ResetState extends APIController
	module.exports = @

	render: (req, cb) ->
		req.resetState(
			(state) ->
				cb(null,state)
			, (error) ->
				cb(error)
			, req.getUserId()
		)