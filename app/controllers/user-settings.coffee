Index = require(app.config.appDir + '/controllers/index.coffee')

class UserSettings extends Index			
	module.exports = @

	run: (req, res) ->
		super