APIController = require(app.config.appDir + '/lib/APIController.coffee')

class API_User_ResetSession extends APIController
	module.exports = @

	render: (req, cb) ->
		req.resetSession(() ->
			cb(null,true)
		)