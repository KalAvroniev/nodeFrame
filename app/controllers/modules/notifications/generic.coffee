class Modules_Notifications_Generic extends app.modules.lib.Controller
	module.exports = @

	run: (req, res, url, cb) ->
		res.view.layout = null
		super
