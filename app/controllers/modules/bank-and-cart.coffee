Controller = require( app.config.appDir + "/lib/Controller.coffee" )

class Modules_ShoppingCart extends Controller
	module.exports = @

	run: (req, res, url) ->
		if req.query.ajax
			res.view.layout = null
			
		res.view.id = 'sidebar'

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
		res.view.user.avatar = {}
		res.view.user.avatar.hasImage = false
		res.view.user.avatar.image = "<img src=\"moo.gif\" alt=\"user avatar image\" />"
		res.view.user.avatar.default = "<span class=\"avatar-default\">no image linked</span>"

		# user upgrade info	
		res.view.upgrade = {}
		res.view.upgrade.monthlyCost = 49

		super