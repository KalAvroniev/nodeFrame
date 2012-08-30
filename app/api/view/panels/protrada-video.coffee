APIController = require(app.config.appDir + '/lib/APIController.coffee')

class API_View_Panels_ProtradaVideo extends APIController
	module.exports = @

	constructor: () ->
		super
		options =
			"requireUserSession": true

	render: (req, cb) ->
		r = {}
		cb(null, r)