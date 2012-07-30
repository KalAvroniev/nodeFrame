Controller = require('../lib/Controller.coffee').Controller

class exports.Controller extends Controller
	
	run: (req, res) ->
		res.view.layout = null
		if not req.session.user
			return res.redirect('/login')
		
		res.ready()
