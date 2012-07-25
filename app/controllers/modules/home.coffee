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
				'id': 'import-domains'
				'h1': 'Import Domains',
				'h2': 'import domains',
				'panel': '/modules/home/panels/import-domains'
			},
			{
				'id': 'list-forsale'
				'h1': 'List for Sale',
				'h2': 'list for sale',
				'panel': '/modules/home/panels/list-forsale'
			}
		]
			
		res.view.showTradingSummary = false
		
		res.ready()
