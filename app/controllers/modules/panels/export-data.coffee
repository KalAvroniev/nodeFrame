Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Modules_Panels_ExportData extends Controller
	module.exports = @

	run: (req, res, url) ->
		super
