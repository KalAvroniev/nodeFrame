Controller = require('../../lib/Controller.coffee').Controller

class exports.Controller extends Controller
	
	run: (req, res) ->
		res.view.layout = null
		res.view.ajax = false
		if req.query.ajax
			res.view.ajax = req.query.ajax
			
		# tabs
		res.view.tabs = [
			{
				'id': 'watchlist',
				'class': 'standout-tab',				
				'h1': 'my watchlist',
				'h2': 'domains you star',
				'panel': '/modules/exchange/panels/watchlist'
			},
			{
				'id': 'export-data',
				'h1': 'export all',
				'h2': 'on-screen data',
				'panel': '/panels/export-data'
			},
		]
		
		res.ready()
