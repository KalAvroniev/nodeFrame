class exports.Controller
	
	run: (params, callback) ->
		if params.when == undefined
			params.when = new Date()
		
			return callback(null, "No 'name' provided.")
		return callback("Hello " + params.name)
