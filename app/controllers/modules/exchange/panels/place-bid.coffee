Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Modules_Exchange_Panels_PlaceBid extends Controller
	module.exports = @

	run: (req, res) ->
		res.view.layout = '../views/layouts/panels'
		res.view.ajax = false
		if req.query.ajax
			res.view.ajax = req.query.ajax
			
		res.ready()
