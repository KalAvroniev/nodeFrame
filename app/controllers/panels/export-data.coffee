Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Panels_ExportData extends Controller
	module.exports = @

	run: (req, res, url) ->
		super
