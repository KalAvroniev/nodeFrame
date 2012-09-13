class API_View_Modules_Exchange_Panels_Watchlist extends app.modules.lib.APIController
	module.exports = @

	constructor: () ->
		super
		options =
			"requireUserSession": true

	render: (req, cb) ->
		r = {}

		# restore state here

		# view elements
		r.tabs = [
			{
				'title': 'Expiring',
				'href': '#expiring',
			},
			{
				'title': 'Pre-auctions',
				'href': '#pre-auction'
			},
			{
				'title': 'Auctions',
				'href': '#auction'
			},
			{
				'title': 'Buy it now',
				'href': '#buy-it-now'
			},
			{
				'title': 'Websites',
				'href': '#websites'
			},
			{
				'title': 'History',
				'href': '#history'
			}
		]
		r.active_tab = '#expiring'

		cb(null, r)