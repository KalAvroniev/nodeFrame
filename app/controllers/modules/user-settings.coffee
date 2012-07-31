Controller = require('../../lib/Controller.coffee').Controller

class exports.Controller extends Controller
	
	run: (req, res) ->
		res.view.layout = null
		res.view.ajax = false
		if req.query.ajax
			res.view.ajax = req.query.ajax
			
		# tabs
		res.view.tabs = [
			#{
			#	'id': 'modal'
			#	'h1': 'Active Modal',
			#	'h2': 'label in here',
			#	'panel': ''
			#},
			#{
			#	'id': 'domain-info'
			#	'h1': 'Detailed',
			#	'h2': 'domain info',
			#	'panel': '/modules/exchange/panels/place-bid'
			#},
			#{
			#	'id': 'watchlist'
			#	'h1': 'My Watchlist',
			#	'h2': 'domains you star',
			#	'panel': '/modules/exchange/panels/watchlist'
			#},
			#{
			#	'id': 'export'
			#	'h1': 'Export',
			#	'h2': 'export data',
			#	'panel': '/panels/export-data'
			#}
		]
			

	# user info
		res.view.user = {}
		res.view.user.userCanUpgrade = true
		res.view.user.fullName = "Andrew Chinn"	
		res.view.user.availableCredits = "657"
		res.view.user.memberType = "free member"	
		res.view.user.membershipExpires = "(this will never expire)"
					
	
	# user upgrade info	
		res.view.upgrade = {}
		res.view.upgrade.monthlyCost = 49
		
		
		
		
		res.ready()
