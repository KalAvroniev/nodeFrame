Admin = require( app.config.appDir + "/controllers/admin.coffee" )

class Modules_BankAndCart extends Admin
	module.exports = @

	run: (req, res, url) ->
		super