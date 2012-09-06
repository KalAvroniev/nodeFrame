Admin = require(app.config.appDir + '/controllers/admin.coffee')

class Modules_UserSettings extends Admin			
	module.exports = @

	run: (req, res, url) ->
		super