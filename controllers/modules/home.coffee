Controller = require('../../lib/Controller.coffee').Controller

class Modules_Home extends Controller
	module.exports = @
	
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
		res.view.showDefaultContent = true

	# user info
		res.view.user = {}
		res.view.user.name = "Protrada testing"
		res.view.user.type = "Free member."
		res.view.user.renewal = "24<sup>th</sup> May, 2012"

	# portfolio health info
		res.view.portfolioHealth = {}
		res.view.portfolioHealth.default = "<p class='ff-icon-before'>This section can show you at a glance, how healthy your portfolio is (by charting it's ROI%), and also how it is trending. <a href='#'>Read more</a> to learn how to take advantage of this feature.</p>"

	# status summary info
		res.view.satusSummary = {}
		res.view.satusSummary.watching = "24"
		res.view.satusSummary.losing = "2"
		res.view.satusSummary.winning = "0"
		res.view.satusSummary.preAuction = "3"
		res.view.satusSummary.pending = "1"

	# tab titles and content
		res.view.contentTabs = {}
		res.view.contentTabs.wholePortfolio = {}
		res.view.contentTabs.wholePortfolio.title = "Complete domain listing"
		res.view.contentTabs.wholePortfolio.intoText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent id augue vitae libero ultricies bl andit eget non lacus. Pellentesque a imperdiet diam."

		res.view.contentTabs.listedForSale = {}
		res.view.contentTabs.listedForSale.title = "Domains listed for sale"
		res.view.contentTabs.listedForSale.intoText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent id augue vitae libero ultricies bl andit eget non lacus. Pellentesque a imperdiet diam."

		res.ready()