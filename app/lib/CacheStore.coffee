util = require('util')

class CacheStore
	module.exports = @
	
	constructor: () -> 
		if app.config.cache.enabled
			store = app.config.cache.stores[app.config.cache.index]
			@CS = app.modules.lib.Cache[store.charAt(0).toUpperCase() + store.substr(1) + 'Adapter']
			@cs = new @CS()
				
	changeStoreSync: (index) ->
		if index < app.config.cache.stores.length
			store = app.config.cache.stores[index]
			@CS = app.modules.lib.Cache[store.charAt(0).toUpperCase() + store.substr(1) + 'Adapter']
			@cs = new @CS()
			app.config.cache.index = index
		else
			app.config.cache.enabled = false
		return
		
	tagSync: (key, tag) ->
		if app.config.cache.enabled
			@cs.tagSync(key, tag)
		
	@hashSync: (key) ->
		if app.config.cache.enabled
			@CS.hashSync(key)
	
	hashTagSync: (key, tag) ->
		if app.config.cache.enabled
			@cs.hashTagSync(key,tag)
		
	read: (key, expire = 0, cb) ->
		if app.config.cache.enabled
			@cs.read(key, expire, cb)
		else
			cb(true)
	
	@static_read: (key, expire = 0, cb) ->
		if app.config.cache.enabled
			@CS.static_read(key, expire, cb)
		else
			cb(true)
		
	write: (key, val, expire = 0, cb) ->
		if app.config.cache.enabled
			@cs.write(key, val, expire, cb)
		else
			cb(true)
	
	flush: (key, cb) ->
		if app.config.cache.enabled
			@cs.flush(key, cb)
		else
			cb(true)
		
	getNameSpace: (key, ts = null, cb) ->	
		if app.config.cache.enabled
			@cs.getNameSpace(key, ts, cb)
		else
			cb(false)	
		
	setNameSpace: (key, ts = null, cb, res) ->		
		if app.config.cache.enabled
			@cs.setNameSpace(key, ts, cb, res)
		else
			res(true)
		
	flushNameSpace: (key, ts = null, cb) ->	
		if app.config.cache.enabled
			@cs.flushNameSpace(key, ts, cb)
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
				Store = app.modules.lib.Cache[store.charAt(0).toUpperCase() + store.substr(1) + 'Adapter']
				store = new Store()
				key = Store.hashSync(val)
				store.write(key, val, 0, (err, res, change) =>
					if change 
						if i + 1 > app.config.cache.index
							app.options.cache.changeStoreSync(i + 1)
							@cacheCheck()
					else if not err
						store.flush(key, (err, res, change) =>
							if change 
								if i + 1 > app.config.cache.index
									app.options.cache.changeStoreSync(i + 1)
									@cacheCheck()
							else if not err
								if i < app.config.cache.index
									app.options.cache.changeStoreSync(i)	
								app.config.cache.enabled = true
						)
				)
			)(i)	