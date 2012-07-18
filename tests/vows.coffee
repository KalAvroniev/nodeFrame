vows = require('vows')
assert = require('assert')
TestUtils = require('./TestUtils.coffee').TestUtils

vows.describe('Test Suite')
	.addBatch({
		'exchange/panels/watchlist':
			'topic': () ->
				return new (require('../app/api/exchange/panels/watchlist.coffee').Controller)

		'test/ping-pong':
			'topic': () ->
				return new (require('../app/api/test/ping-pong.coffee').Controller)

			'testWithName': (topic) ->
				topic.testWithName(new TestUtils(topic))

			'testNoName': (topic) ->
				topic.testNoName(new TestUtils(topic))

	})
	.run((result) ->
		console.log('*' + result2)
	)
