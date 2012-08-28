Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Panels_AdvancedSearch extends Controller
	module.exports = @

	run: (req, res) ->
		res.ready()
