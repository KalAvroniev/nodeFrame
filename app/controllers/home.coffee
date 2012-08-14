Index = require(app.config.appDir + '/controllers/index.coffee')

class Home extends Index			
	module.exports = @
	
	run: (req, res) ->
		super