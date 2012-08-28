Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Modules_Home_Panels_ImportDoimains extends Controller
	module.exports = @

	run: (req, res) ->
		res.view.ajax = false
		if req.query.ajax
			res.view.ajax = req.query.ajax
			
		res.ready()
