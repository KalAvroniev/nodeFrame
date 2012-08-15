Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Panels_ExportData extends Controller
	module.exports = @
	
	run: (req, res) ->
		res.view.layout = '../views/layouts/mini-panels'		
		res.ready()
