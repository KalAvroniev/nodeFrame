Controller = require('../../../../lib/Controller.coffee').Controller

class Modules_Home_Panels_ImportDoimains extends Controller
	module.exports = @
	
	run: (req, res) ->
		res.view.layout = '../views/layouts/mini-panels'
		res.view.ajax = false
		if req.query.ajax
			res.view.ajax = req.query.ajax
		res.ready()
