class API_Test_PingPong
	module.exports = @

	validate: {
		"name": {
			"description": "A persons name.",
			"type": "string"
			"required": true
		}	
	}

	run: (req) ->
		return req.success("Hello " + req.params.name)

	testWithName: (test) ->
		params = {
			'name': 'Bob'
		}
		test.run(params
			, (result) ->
				test.assert.equal("Hello " + params.name, result)
			, (error) ->
				test.fail(error.message)
		)

	testNoName: (test) ->
		test.run({}
			, (result) ->
				test.fail("This test is supposed to fail, instead got " + result)
			, (error) ->
				# this is supposed to happen
		)