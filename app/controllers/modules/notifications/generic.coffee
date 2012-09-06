Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Modules_Notifications_Generic extends Controller
	module.exports = @

	run: (req, res, url) ->
		res.view.layout = null
		super
