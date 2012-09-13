class Modules_Grid_Row extends app.modules.lib.Controller
	module.exports = @

	run: (req, res, url) ->
		res.view.layout = null
		super
