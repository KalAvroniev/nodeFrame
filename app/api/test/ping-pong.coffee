class exports.Controller
	
	run: (params, callback) ->
		if params.name == undefined
			return callback(null, "No 'name' provided.")
		return callback("Hello " + params.name)
