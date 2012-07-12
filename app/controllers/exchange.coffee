Controller = require('../lib/Controller.coffee').Controller

class exports.Controller extends Controller
	
	run: (req, res) ->
		res.view.layout = null
		res.view.viewModule = false
		res.setView('index')
		res.view.module = 'home'
		res.ready()
