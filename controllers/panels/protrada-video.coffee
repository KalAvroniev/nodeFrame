Controller = require('../../lib/Controller.coffee').Controller

class Panels_ProtradaVideo extends Controller
	module.exports = @
	
	run: (req, res) ->
		res.view.layout = '../views/layouts/mini-video-panels'		
		res.ready()
