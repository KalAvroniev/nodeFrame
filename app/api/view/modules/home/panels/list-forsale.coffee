class exports.Controller

	validate: {
	}
	
	options: {
		"requireUserSession": true
	}
	
	run: (req) ->
		r = {}
		return req.success(r)
