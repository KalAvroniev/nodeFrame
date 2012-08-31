class CacheStore

	module.exports = @
	
	constructor: () -> #index = 0
		@index = 0 #index
		store = app.config.cacheStore[@index]
		@CS = require(app.config.appDir + '/lib/Cache/' + store.charAt(0).toUpperCase() + store.substr(1) + 'Adapter.coffee')
		@cs = new @CS()
		
	changeStore: (index) ->
		###
		if index
			@index -= index
		if @index + 1 < app.config.cacheStore.length
			@constructor(++@index)
		else
			app.config.cache = false
		###
		if index + 1 < app.config.cacheStore.length
			store = app.config.cacheStore[++index]
			@CS = require(app.config.appDir + '/lib/Cache/' + store.charAt(0).toUpperCase() + store.substr(1) + 'Adapter.coffee')
			@cs = new @CS()
		else
			app.config.cache = false
		return index
		
	tag: (key, tag) ->
		if app.config.cache
			@cs.tag(key, tag)
		
	@hash: (key) ->
		if app.config.cache
			@CS.hash(key)
	
	hashTag: (key, tag) ->
		if app.config.cache
			@cs.hashTag(key,tag)
		
	read: (key, cb) ->
		index = @index
		if app.config.cache
			@cs.read(key, (err, response, change) =>
				if change && app.config.cache
					@index = @changeStore(index)
					@read(key, cb)
				else
					cb(err, response)
			)
		else
			cb(true)
	
	@static_read: (key, cb) ->
		index = @index
		if app.config.cache
			@CS.static_read(key, (err, response, change) =>
				if change
					@index = @changeStore(index)
					CacheStore.static_read(key, cb)
				else
					cb(err, response)
			)
		else
			cb(true)
		
	write: (key, val, cb) ->
		index = @index
		if app.config.cache
			@cs.write(key, val, (err, response, change) =>
				if change
					@index = @changeStore(index)
					@write(key, cb)
				else
					cb(err, response)
			)
		else
			cb(true)
	
	flush: (key, cb) ->
		index = @index
		if app.config.cache
			@cs.flush(key, (err, response, change) =>
				if change
					@index = @changeStore(index)
					@flush(key, cb)
				else
					cb(err, response)
			)
		else
			cb(true)
		
	getNameSpace: (key, cb) ->	
		index = @index
		if app.config.cache
			@cs.getNameSpace(key, (err, response, change) =>
				if change
					@index = @changeStore(index)
					@getNameSpace(key, cb)
				else
					cb(err, response)
			)
		else
			cb(false)	
		
	setNameSpace: (key, cb, res) ->		
		index = @index
		if app.config.cache
			@cs.setNameSpace(key, cb, (err, response, change) =>
				if change
					@index = @changeStore(index)
					@setNameSpace(key, cb, res)
				else
					res(err, response)
			)
		else
			res(true)
		
	flushNameSpace: (key, cb) ->	
		index = @index
		if app.config.cache
			@cs.flushNameSpace(key, (err, response, change) =>
				if change
					@index = @changeStore(index)
					@flushNameSpace(key, cb)
				else
					cb(err, response)
			)
		else
			cb(true)