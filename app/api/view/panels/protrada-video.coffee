class API_View_Panels_ProtradaVideo
	module.exports = @

	validate: {
	}

	options: {
		"requireUserSession": true
	}

	run: (req) ->
		r = {}
		return req.success(r)