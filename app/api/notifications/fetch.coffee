class exports.Controller

	validate: {
		"limit": {
			"description": "The maximu number of recent notifications to return.",
			"type": "integer"
			"required": false,
			"default": 10
		}
	}
	
	run: (req) ->
		# will return the same static notifcations for everyone
		notifs = [
			{
				'type': 'preview'
			},
			{
				'type': 'dns-change'
			},
			{
				'type': 'max-bid-lost'
			}
		]
		
		return req.success({
			'notifications': notifs
		})
