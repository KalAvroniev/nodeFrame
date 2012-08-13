GridModel = require("../../models/GridModel.coffee").GridModel

class API_Exchange_Grid
	module.exports = @

	validate: {}

	options: {
		requireUserSession: true
	}

	run: ( req ) ->
		grid = new GridModel()

		# header
		grid.addHeaderLabel({
			action: "stickyswitch",
			span: 2,
			title: "Stick"
		})

		grid.addHeaderLabel({
			span: 2,
			title: "Basic domain info"
		})

		grid.addHeaderLabel({
			span: 4,
			title: "Price/value info"
		})

		grid.addHeaderLabel({
			span: 2,
			title: "Performance info"
		})

		grid.addHeaderLabel({
			span: 3,
			title: "Domain registration info"
		})

		grid.addHeaderLabel({
			span: 4,
			title: "Extension info"
		})

		# columns
		grid.addMasterColumn({
			span: 2,
			title: "Bulk"
		})

		grid.addMasterColumn({
			filter: {
				id: "top-actions",
				type: "menu",
				values: [ "Action 1", "Action 2", "Action 3" ]
			},
			title: "Top action(s)"
		})

		grid.addMasterColumn({
			sortable: true,
			filter: {
				id: "domain-title",
				active: true,
				type: "textcombo",
				values: [ "Contains", "Beginning with", "Ending with" ]
			},
			title: "Domain title"
		})

		grid.addMasterColumn({
			title: "Offers"
		})

		grid.addMasterColumn({
			sortable: true,
			filter: {
				id: "cost",
				type: "text"
			},
			title: "Cost"
		})

		grid.addMasterColumn({
			sortable: true,
			filter: {
				id: "appraised",
				type: "text"
			},
			title: "Appraised"
		})

		grid.addMasterColumn({
			title: "Unrealised"
		})

		grid.addMasterColumn({
			title: "Income"
		})

		grid.addMasterColumn({
			title: "ROI%"
		})

		grid.addMasterColumn({
			sortable: true,
			filter: {
				id: "accquired",
				type: "menu",
				values: [ "tomorrow", "2 days", "date range" ]
			},
			title: "Acquired date"
		})

		grid.addMasterColumn({
			sortable: true,
			filter: {
				id: "expiring",
				type: "menu",
				values: [ "tomorrow", "2 days", "date range" ]
			},
			title: "Expiry date"
		})

		grid.addMasterColumn({
			filter: {
				id: "status",
				type: "menu",
				values: [ "pending", "active", "expired", "dropping" ]
			},
			title: "Status"
		})

		grid.addMasterColumn({
			title: ".com"
		})

		grid.addMasterColumn({
			title: ".net"
		})

		grid.addMasterColumn({
			title: ".org"
		})

		grid.addMasterColumn({
			title: ".edu"
		})

		###
		some other actions:
		
		{ id: "make-offer", path: "/modules/exchange/panels", tooltip: "Make an offer", icon: "?", text: "Offer" }

		{ id: "build-website", path: "???", tooltip: "Build website", icon: "X" }
		{ id: "sell-domain", path: "???", tooltip: "List domain for sale", icon: "^", text: "Sell" }
		{ id: "buy-domain", path: "???", tooltip: "Buy this domain now", icon: "-", text: "Buy" }
		###

		grid.addAction({
			id: "domain-details",
			path: "/",
			tooltip: "View domain details",
			icon: "G"
		});

		grid.addAction({
			id: "place-bid",
			path: "/modules/exchange/panels",
			tooltip: "Bid on this domain",
			icon: "W",
			text: "Bid"
		});

		# data
		for i in [0..9]
			grid.addRecord({
				selected: false,
				star: false,
				buttons: [ "domain-details", "place-bid" ],
				domain: "353cards",
				tld: "com"
			})

		return req.success( grid.result() )