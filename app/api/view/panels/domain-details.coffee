class API_View_Panels_DomainDetails
	module.exports = @

	validate: {
	}

	options: {
		"requireUserSession": true
	}

	run: (req) ->
		r = {}
		return req.success(r)