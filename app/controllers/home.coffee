Admin = require(app.config.appDir + '/controllers/admin.coffee')
util = require('util')

class Home extends Admin			
	module.exports = @
	
	constructor: () ->
		super
		@modMasterParams(id: "defaultSearch")

	run: (req, res, url) ->	
		super