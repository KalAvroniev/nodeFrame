Controller = require('../lib/Controller.coffee').Controller

class exports.Controller extends Controller
	
	run: (req, res) ->
		if not req.session.user
			res.redirect('/login')
		else
			res.ready()
