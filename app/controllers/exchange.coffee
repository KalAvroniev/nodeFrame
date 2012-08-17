Index = require(app.config.appDir + '/controllers/index.coffee')

class Exchange extends Index			
	module.exports = @
			
	run: (req, res) ->
		super