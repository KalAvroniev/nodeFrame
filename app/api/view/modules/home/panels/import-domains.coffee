class API_View_Modules_Home_Panels_ImportDomains
	module.exports = @

	validate: {
	}

	options: {
		"requireUserSession": true
	}

	run: (req) ->
		r = {}
		return req.success(r)