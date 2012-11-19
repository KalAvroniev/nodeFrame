class API_Test_PingPong extends app.modules.lib.APIController
	module.exports = @

	constructor: () ->
		super
		validate =
			"name"				: 
				"description"	: "A persons name."
				"type"			: "string"
				"required"		: true

	render: (req, cb) ->
		cb(null, "Hello " + req.params.name)

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