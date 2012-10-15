app = require('../app')
chai = require('chai')
should = chai.should()

describe('app:', () ->
	it('test should have app property', () ->
		app.should.have.property('app')
	)
	
	it('app lenght should be 10', () ->
		tmp = Object.keys(app).length
		tmp.should.equal(10)
	)
	it('app should have options, modules and config properties', () ->
		app.should.have.property('options')
		app.should.have.property('modules')
		app.should.have.property('config')
	)
	it('modules lenght should be 3', () ->
		tmp = Object.keys(app.modules).length
		tmp.should.equal(3)
	)
	it('configs should not be empty', () ->
		tmp = Object.keys(app.config).length
		tmp.should.be.above(0)
	)
	it('modules should have lib, controllers and api', () ->
		app.modules.should.have.property('lib')
		app.modules.should.have.property('controllers')
		app.modules.should.have.property('api')
	)
	it('cache adapter should be memcache')
	it('cache failover')
	it('cache recover')
	it('all modules should be loaded')
	it('delete minified files')
	it('all api modules should be loaded')
)

