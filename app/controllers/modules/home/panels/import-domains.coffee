Controller = require('../../../../lib/Controller.coffee').Controller

class exports.Controller extends Controller
	
	run: (req, res) ->
		res.view.layout = '../layouts/mini-panels'
		res.view.ajax = false
		if req.query.ajax
			res.view.ajax = req.query.ajax
		res.ready()
