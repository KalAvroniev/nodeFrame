Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Notifications_Generic extends Controller
	module.exports = @

	run: (req, res, url) ->
		res.view.layout = null
		super
