class Modules_Home_Panels_ListForsale extends app.modules.lib.Controller
	module.exports = @

	run: (req, res, url, cb) ->
		res.view.ajax = false
		if req.query.ajax
			res.view.ajax = req.query.ajax
			
		super
