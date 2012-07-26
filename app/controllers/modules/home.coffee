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
				'id': 'import-domains',
				'class': 'standout-tab',
				'h1': 'import domains',
				'h2': 'into portfolio',
				'panel': '/modules/home/panels/import-domains',
				'panel_size': 'mini-panel'
			},
			{
				'id': 'export-data',
				'h1': 'export all',
				'h2': 'on-screen data',
				'panel': '/panels/export-data',
				'panel_size': 'mini-panel'
			},
			{
				'id': 'list-forsale',
				'h1': 'list domains',
				'h2': 'for-sale',
				'panel': '/modules/home/panels/list-forsale',
				'panel_size': 'panel'
			}
		]
			
		res.view.showTradingSummary = false
		
		res.ready()
