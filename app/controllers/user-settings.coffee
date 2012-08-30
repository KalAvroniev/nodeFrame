Admin = require(app.config.appDir + '/controllers/admin.coffee')

class UserSettings extends Admin			
	module.exports = @

	run: (req, res, url) ->
		super