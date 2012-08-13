Controller = require('../../lib/Controller.coffee').Controller

class Panels_AdvancedSearch extends Controller
	module.exports = @
	
	run: (req, res) ->
		res.view.layout = '../views/layouts/panels'		
		res.ready()
