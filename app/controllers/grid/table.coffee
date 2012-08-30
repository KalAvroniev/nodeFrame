Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Grid_Table extends Controller
	module.exports = @

	run: (req, res, url) ->
		res.view.layout = null
		super
