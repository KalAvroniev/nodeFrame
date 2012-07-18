class exports.Controller
	
	run: (params, callback) ->
		if params.name == undefined
			return callback(null, "No 'name' provided.")
		return callback("Hello " + params.name)
		
	testWithName: (test) ->
		params = {
			'name': 'Bob'
		}
		test.run(
			params,
			(result, error) ->
				if error
					test.fail(error)
				test.assert.equal("Hello " + params.name, result)
		)
		
	testNoName: (test) ->
		test.run(
			{},
			(result, error) ->
				if not error
					test.fail("No error message was returned, when one was expected.")
		)
