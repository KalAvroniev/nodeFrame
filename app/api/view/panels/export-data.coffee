class exports.Controller

	validate: {
	}
	
	run: (req) ->
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
		
		return req.success(r)
		
	testBasic: (test) ->
		test.run(
			{},
			(result) ->
				test.assert.equal(result.tabs.length, 6)
			, (error) ->
				test.fail(error)
		)
