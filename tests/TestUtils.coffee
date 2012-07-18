assert = require('assert')

class exports.TestUtils

	constructor: (@controller) ->
		@assert = assert
		
	fail: (message) ->
		assert.fail("", "", message)
	
	run: (params, callback) ->
		@controller.run(params, callback)
