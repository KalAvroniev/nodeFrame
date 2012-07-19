assert = require('assert')
JsonRpcServer = require('../app/lib/JsonRpcServer.coffee').JsonRpcServer

class exports.TestUtils

	constructor: (@endpoint, @controller, @jsonRpcServer) ->
		@assert = assert
		
	fail: (message) ->
		assert.fail("", "", message)
	
	run: (params, success, failure) ->
		@jsonRpcServer.call(
			@endpoint,
			params,
			(result, error) ->
				if error
					return failure(error)
				return success(result)
		)
