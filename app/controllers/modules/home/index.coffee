util = require('util')

class Modules_Home extends app.modules.controllers.admin			
	module.exports = @
	
	constructor: () ->
		super
		@modMasterParams(id: "defaultSearch")

	run: (req, res, url) ->	
		super