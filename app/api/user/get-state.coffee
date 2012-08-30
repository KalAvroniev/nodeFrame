APIController = require(app.config.appDir + '/lib/APIController.coffee')

class API_User_GetState extends APIController
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