class Modules_Home_Panels_ImportDoimains extends app.modules.lib.Controller
	module.exports = @

	run: (req, res, url) ->
		res.view.ajax = false
		if req.query.ajax
			res.view.ajax = req.query.ajax
			
		super
