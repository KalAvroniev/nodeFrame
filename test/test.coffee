test = require('../app')
chai = require('chai')
should = chai.should()

describe('test', () ->
	it('should run', () ->
		test.should.have.property('app');
	)
)