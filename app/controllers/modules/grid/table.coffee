class Modules_Grid_Table extends app.modules.lib.Controller
	module.exports = @

	run: (req, res, url, cb) ->
		res.view.layout = null
		super
