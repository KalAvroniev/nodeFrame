Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Grid_Row extends Controller
	module.exports = @

	run: (req, res, url) ->
		res.view.layout = null
		super
