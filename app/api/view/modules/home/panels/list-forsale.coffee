class API_View_Modules_Home_Panels_ListForsale
	module.exports = @

	validate: {
	}
	
	options: {
		"requireUserSession": true
	}
	
	run: (req) ->
		r = {}
		return req.success(r)
