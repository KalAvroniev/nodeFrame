class API_Notifications_Fetch
	module.exports = @

	validate: {
		"limit": {
			"description": "The maximum number of recent notifications to return.",
			"type": "integer"
			"required": false,
			"default": 10
		}
	}

	run: (req) ->
		# will return the same static notifcations for everyone
		notifs = [
			{
				'type': 'preview',
				'title': 'Preview',
				'time_ago': '4 hours',
				'h5': "1 hour left & you're currently winning!",
				'domain': 'icanhazauction.com',
				'action_description': 'do something',
				'description': "The auction for this domain will finish on 15th Jan, " +
					"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
					'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
			},
			{
				'type': 'dns-change',
				'title': 'DNS Change',
				'time_ago': '6 hours',
				'h5': "1 hour left & you're currently winning!",
				'domain': 'icanhazauction.com',
				'action_description': 'do something',
				'description': "The auction for this domain will finish on 15th Jan, " +
					"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
					'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
			},
			{
				'type': 'max-bid-lost',
				'title': 'Max Bid Lost',
				'time_ago': '8 hours',
				'h5': "1 hour left & you're currently winning!",
				'domain': 'icanhazauction.com',
				'action_description': 'do something',
				'description': "The auction for this domain will finish on 15th Jan, " +
					"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
					'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
			},
			{
				'type': 'domain-expire',
				'title': 'Preview',
				'time_ago': '4 hours',
				'h5': "1 hour left & you're currently winning!",
				'domain': 'icanhazauction.com',
				'action_description': 'do something',
				'description': "The auction for this domain will finish on 15th Jan, " +
					"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
					'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
			},
			{
				'type': 'winning',
				'title': 'DNS Change',
				'time_ago': '6 hours',
				'h5': "1 hour left & you're currently winning!",
				'domain': 'icanhazauction.com',
				'action_description': 'do something',
				'description': "The auction for this domain will finish on 15th Jan, " +
					"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
					'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
			},
			{
				'type': 'lost-domain',
				'title': 'Max Bid Lost',
				'time_ago': '8 hours',
				'h5': "1 hour left & you're currently winning!",
				'domain': 'icanhazauction.com',
				'action_description': 'do something',
				'description': "The auction for this domain will finish on 15th Jan, " +
					"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
					'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
			},

			{
				'type': 'losing',
				'title': 'Preview',
				'time_ago': '4 hours',
				'h5': "1 hour left & you're currently winning!",
				'domain': 'icanhazauction.com',
				'action_description': 'do something',
				'description': "The auction for this domain will finish on 15th Jan, " +
					"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
					'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
			},
			{
				'type': 'for-sale',
				'title': 'DNS Change',
				'time_ago': '6 hours',
				'h5': "1 hour left & you're currently winning!",
				'domain': 'icanhazauction.com',
				'action_description': 'do something',
				'description': "The auction for this domain will finish on 15th Jan, " +
					"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
					'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
			},
			{
				'type': 'domain-won',
				'title': 'Max Bid Lost',
				'time_ago': '8 hours',
				'h5': "1 hour left & you're currently winning!",
				'domain': 'icanhazauction.com',
				'action_description': 'do something',
				'description': "The auction for this domain will finish on 15th Jan, " +
					"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
					'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
			}		
		]

		return req.success({
			'notifications': notifs
		})