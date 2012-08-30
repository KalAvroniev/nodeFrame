Admin = require(app.config.appDir + '/controllers/admin.coffee')

class Exchange extends Admin			
	module.exports = @

	run: (req, res, url) ->
		super