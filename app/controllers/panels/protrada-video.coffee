Controller = require('../../lib/Controller.coffee').Controller

class exports.Controller extends Controller
	
	run: (req, res) ->
		res.view.layout = '../views/layouts/mini-video-panels'		
		res.ready()
