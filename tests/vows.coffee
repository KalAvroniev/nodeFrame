vows = require('vows')
assert = require('assert')
TestUtils = require('./TestUtils.coffee').TestUtils
JsonRpcServer = require('../app/lib/JsonRpcServer.coffee').JsonRpcServer

jsonRpcServer = new JsonRpcServer()
jsonRpcServer.registerMethods('../app/api')

vows.describe('Test Suite')
	.addBatch({
		'exchange/panels/watchlist':
			'topic': () ->
				return new (require('../app/api/exchange/panels/watchlist.coffee').Controller)

		'push/notification':
			'topic': () ->
				return new (require('../app/api/push/notification.coffee').Controller)

		'test/ping-pong':
			'topic': () ->
				return new (require('../app/api/test/ping-pong.coffee').Controller)

			'testWithName': (topic) ->
				topic.testWithName(new TestUtils('test/ping-pong', topic, jsonRpcServer))

			'testNoName': (topic) ->
				topic.testNoName(new TestUtils('test/ping-pong', topic, jsonRpcServer))

	})
	.run()
