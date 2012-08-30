Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Modules_Exchange_Panels_Watchlist extends Controller
	module.exports = @

	run: (req, res, url) ->
		res.view.ajax = false
		if req.query.ajax
			res.view.ajax = req.query.ajax
			
		super
