Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Modules_UserSettings extends Controller
	module.exports = @

	run: (req, res) ->
		if req.query.ajax
			res.view.layout = null

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
		res.view.user.avatar.image = "<img src='moo.gif' alt='user avatar image' />"
		res.view.user.avatar.default = "<span class='avatar-default'>no image linked</span>"

		res.view.user.social = {}
		res.view.user.social.hasSocialLinked = true #this should be calculated automatically
		res.view.user.social.facebook = {}	
		res.view.user.social.facebook.connectedAccount = true
		res.view.user.social.facebook.fbUsername = ""
		res.view.user.social.facebook.default = "<span class='social-default'>no account linked</span>"			
		res.view.user.social.twitter = {}
		res.view.user.social.twitter.connectedAccount = false
		res.view.user.social.twitter.twUsername = ""
		res.view.user.social.twitter.default = "<span class='social-default'>no account linked</span>"	

		res.view.user.externalAccounts = {}
		res.view.user.externalAccounts.buying = {}

		res.view.user.externalAccounts.buying.godaddy = {}
		res.view.user.externalAccounts.buying.godaddy.sourceSprite = "GoDaddy"	
		res.view.user.externalAccounts.buying.godaddy.isShown = false
		res.view.user.externalAccounts.buying.godaddy.isAlreadyLinked = true

		res.view.user.externalAccounts.buying.fabulous = {}
		res.view.user.externalAccounts.buying.fabulous.sourceSprite = "Fabulous"			
		res.view.user.externalAccounts.buying.fabulous.isShown = true
		res.view.user.externalAccounts.buying.fabulous.isAlreadyLinked = false		

		res.view.user.externalAccounts.buying.namejet = {}
		res.view.user.externalAccounts.buying.namejet.sourceSprite = "Namejet"			
		res.view.user.externalAccounts.buying.namejet.isShown = true
		res.view.user.externalAccounts.buying.namejet.isAlreadyLinked = false	

		res.view.user.externalAccounts.buying.afternic = {}
		res.view.user.externalAccounts.buying.afternic.sourceSprite = "Afternic"
		res.view.user.externalAccounts.buying.afternic.isShown = true
		res.view.user.externalAccounts.buying.afternic.isAlreadyLinked = false		

		res.view.user.externalAccounts.buying.bido = {}
		res.view.user.externalAccounts.buying.bido.sourceSprite = "Bido"
		res.view.user.externalAccounts.buying.bido.isShown = true
		res.view.user.externalAccounts.buying.bido.isAlreadyLinked = true	

		res.view.user.externalAccounts.buying.pool = {}
		res.view.user.externalAccounts.buying.pool.sourceSprite = "Pool.com"
		res.view.user.externalAccounts.buying.pool.isShown = true
		res.view.user.externalAccounts.buying.pool.isAlreadyLinked = false	

		res.view.user.externalAccounts.buying.snapNames = {}
		res.view.user.externalAccounts.buying.snapNames.sourceSprite = "Snap Names"
		res.view.user.externalAccounts.buying.snapNames.isShown = true
		res.view.user.externalAccounts.buying.snapNames.isAlreadyLinked = false	



		res.view.user.externalAccounts.selling = {}

		res.view.user.externalAccounts.selling.godaddy = {}
		res.view.user.externalAccounts.selling.godaddy.sourceSprite = "GoDaddy"	
		res.view.user.externalAccounts.selling.godaddy.isShown = true
		res.view.user.externalAccounts.selling.godaddy.isAlreadyLinked = true

		res.view.user.externalAccounts.selling.namejet = {}
		res.view.user.externalAccounts.selling.namejet.sourceSprite = "Namejet"			
		res.view.user.externalAccounts.selling.namejet.isShown = true
		res.view.user.externalAccounts.selling.namejet.isAlreadyLinked = false		

		res.view.user.externalAccounts.selling.sedo = {}
		res.view.user.externalAccounts.selling.sedo.sourceSprite = "Sedo"
		res.view.user.externalAccounts.selling.sedo.isShown = true
		res.view.user.externalAccounts.selling.sedo.isAlreadyLinked = false

		res.view.user.externalAccounts.selling.snapNames = {}
		res.view.user.externalAccounts.selling.snapNames.sourceSprite = "Snap Names"
		res.view.user.externalAccounts.selling.snapNames.isShown = true
		res.view.user.externalAccounts.selling.snapNames.isAlreadyLinked = true	

		# user upgrade info	
		res.view.upgrade = {}
		res.view.upgrade.monthlyCost = 49

		res.ready()