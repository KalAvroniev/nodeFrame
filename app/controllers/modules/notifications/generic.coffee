class Modules_Notifications_Generic extends app.modules.lib.Controller
	module.exports = @

	run: (req, res, url) ->
		res.view.layout = null
		super
