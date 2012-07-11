Controller = require('../lib/Controller.coffee').Controller

class exports.Controller extends Controller
	
	run: (req, res) ->
		res.view.layout = false
		res.view.error = ''
		if req.query.error
			res.view.error = req.query.error
		res.ready()
