Controller = require('../../lib/Controller.coffee').Controller

class Panels_DomainDetails extends Controller
	module.exports = @
	
	run: (req, res) ->
		res.view.layout = '../views/layouts/mini-panels'		
		res.ready()
