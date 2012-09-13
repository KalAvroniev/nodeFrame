class Modules_Grid_Table extends app.modules.lib.Controller
	module.exports = @

	run: (req, res, url) ->
		res.view.layout = null
		super
