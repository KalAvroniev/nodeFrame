util = require('util')

class CacheStore

	module.exports = @
	
	constructor: () -> 
		if app.config.cache.enabled
			store = app.config.cache.stores[app.config.cache.index]
			@CS = require(app.config.appDir + '/lib/Cache/' + store.charAt(0).toUpperCase() + store.substr(1) + 'Adapter.coffee')
			@cs = new @CS()
				
	changeStore: (index) ->
		if index < app.config.cache.stores.length
			store = app.config.cache.stores[index]
			@CS = require(app.config.appDir + '/lib/Cache/' + store.charAt(0).toUpperCase() + store.substr(1) + 'Adapter.coffee')
			#@cs.destructor()
			@cs = new @CS()
			app.config.cache.index = index
		else
			app.config.cache.enabled = false
		return
		
	tag: (key, tag) ->
		if app.config.cache.enabled
			@cs.tag(key, tag)
		
	@hash: (key) ->
		if app.config.cache.enabled
			@CS.hash(key)
	
	hashTag: (key, tag) ->
		if app.config.cache.enabled
			@cs.hashTag(key,tag)
		
	read: (key, cb) ->
		if app.config.cache.enabled
			@cs.read(key, cb)
		else
			cb(true)
	
	@static_read: (key, cb) ->
		if app.config.cache.enabled
			@CS.static_read(key, cb)
		else
			cb(true)
		
	write: (key, val, cb) ->
		if app.config.cache.enabled
			@cs.write(key, val, cb)
		else
			cb(true)
	
	flush: (key, cb) ->
		if app.config.cache.enabled
			@cs.flush(key, cb)
		else
			cb(true)
		
	getNameSpace: (key, cb) ->	
		if app.config.cache.enabled
			@cs.getNameSpace(key, cb)
		else
			cb(false)	
		
	setNameSpace: (key, cb, res) ->		
		if app.config.cache.enabled
			@cs.setNameSpace(key, cb, res)
		else
			res(true)
		
	flushNameSpace: (key, cb) ->	
		if app.config.cache.enabled
			@cs.flushNameSpace(key, cb)
		else
			cb(true)
			
	cacheCheck: () -> 
		start = if not app.config.cache.enabled then app.config.cache.stores.length - 1 else app.config.cache.index
		if start < 0
			return
		val = 'test'
		for i in [start..0] by -1
			((i) =>
				store = app.config.cache.stores[i]
				Store = require(app.config.appDir + '/lib/Cache/' + store.charAt(0).toUpperCase() + store.substr(1) + 'Adapter.coffee')
				store = new Store()
				key = Store.hash(val)
				store.write(key, val, (err, res, change) =>
					if change 
						if i + 1 > app.config.cache.index
							app.options.cache.changeStore(i + 1)
							@cacheCheck()
					else if not err
						store.flush(key, (err, res, change) =>
							if change 
								if i + 1 > app.config.cache.index
									app.options.cache.changeStore(i + 1)
									@cacheCheck()
							else if not err
								if i < app.config.cache.index
									app.options.cache.changeStore(i)	
								app.config.cache.enabled = true
						)
				)
			)(i)	