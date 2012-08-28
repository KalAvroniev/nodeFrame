Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Panels_DomainDetails extends Controller
	module.exports = @

	run: (req, res) ->	
		res.ready()
