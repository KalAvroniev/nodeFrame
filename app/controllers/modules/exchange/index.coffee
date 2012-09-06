Admin = require(app.config.appDir + '/controllers/admin.coffee')

class Modules_Exchange extends Admin			
	module.exports = @

	run: (req, res, url) ->
		super