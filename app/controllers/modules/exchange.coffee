Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Modules_Exchange extends Controller
	module.exports = @
	
	run: ( req, res ) ->
		if req.query.ajax
			res.view.layout = null

		# tabs
		res.view.tabs = [
			{
				id: "watchlist",
				class: "standout-tab",
				h1: "my watchlist",
				h2: "domains you star",
				panel: "/modules/exchange/panels/watchlist",
				panel_size: "panel"
			},
			{
				id: "export-data",
				h1: "export all",
				h2: "on-screen data",
				panel: "/panels/export-data",
				panel_size: "mini-panel"
			}
		]

		res.view.searchResults = {}
		res.view.searchResults.state = true
		res.view.searchResults.searchString = "moo"

		res.view.contentTabs = {}
		res.view.contentTabs.expiring = {}
		res.view.contentTabs.expiring.title = "expiring domains listing"
		res.view.contentTabs.expiring.intoText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent id augue vitae libero ultricies bl andit eget non lacus. Pellentesque a imperdiet diam."
		res.view.contentTabs.auctions = {}
		res.view.contentTabs.auctions.title = "auction domains listing"
		res.view.contentTabs.auctions.intoText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent id augue vitae libero ultricies bl andit eget non lacus. Pellentesque a imperdiet diam."
		res.view.contentTabs.dropping = {}
		res.view.contentTabs.dropping.title = "dropping domains listing"
		res.view.contentTabs.dropping.intoText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent id augue vitae libero ultricies bl andit eget non lacus. Pellentesque a imperdiet diam."

		res.view.contentTabs.websites = {}
		res.view.contentTabs.websites.title = "websites domains listing"
		res.view.contentTabs.websites.intoText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent id augue vitae libero ultricies bl andit eget non lacus. Pellentesque a imperdiet diam."

		res.view.contentTabs.history = {}
		res.view.contentTabs.history.title = "history of sales"
		res.view.contentTabs.history.intoText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent id augue vitae libero ultricies bl andit eget non lacus. Pellentesque a imperdiet diam."
		res.view.contentTabs.newRegistrations = {}
		res.view.contentTabs.newRegistrations.title = "new domains listing"
		res.view.contentTabs.newRegistrations.intoText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent id augue vitae libero ultricies bl andit eget non lacus. Pellentesque a imperdiet diam."

		res.ready()