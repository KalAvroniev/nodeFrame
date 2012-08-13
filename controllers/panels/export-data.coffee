Controller = require('../../lib/Controller.coffee').Controller

class Panels_ExportData extends Controller
	module.exports = @
	
	run: (req, res) ->
		res.view.layout = '../views/layouts/mini-panels'		
		res.ready()
