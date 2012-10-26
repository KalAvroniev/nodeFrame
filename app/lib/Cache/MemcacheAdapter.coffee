crypto = require('crypto')

class MemcacheAdapter
	module.exports = @
			
	constructor: () ->
			
	tagSync: (key, tag) ->
		key = tag + '/' + key
		
	@hashSync: (key) ->
		key = crypto.createHash('md5').update(key).digest('hex')
	
	hashTagSync: (key, tag) ->
		@tagSync(MemcacheAdapter.hashSync(key), tag)
		
	read: (key, expire = 0, cb) ->
		app.options.memcache.get(key, (err, res) ->
			if err
				cb(err, res, true)
			else if not res
				cb(true)
			else
				cb(err, res)			
		)
	
	@static_read: (key, expire = 0, cb) ->
		app.options.memcache.get(key, (err, res) ->
			if err
				cb(err, res, true)
			else if not res
				cb(true)
			else
				cb(err, res)			
		)
	
	write: (key, value, expire = 0, cb) -> 
		app.options.memcache.replace(key, value, expire, (err, res) ->
			if not res
				app.options.memcache.set(key, value, expire, (err, res) ->
					if err
						cb(err, res, true)
					else if not res
						cb(true)
					else
						cb(err)					
				)
			else if err
				cb(err, res, true)
			else
				cb(err)
		)
		
	flush: (key, cb) ->
		app.options.memcache.del(key, (err, res) ->
			if err
				cb(err, res, true)
			else if not res
				cb(true)
			else
				cb(err)
		)
		
	getNameSpace: (ns, ts = null, cb) ->
		if not ts?
			ns = MemcacheAdapter.hashSync(ns)
			
		MemcacheAdapter.static_read(ns, 0, cb)
		
	setNameSpace: (ns, ts = null, cb, res) ->
		date = new Date()
		if not ts?
			ts = String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60) 
			ns = MemcacheAdapter.hashSync(ns)
		
		@write(ns, ts, 0, (err, response) ->
			if not err
				cb(ns, ts, res)
			else
				res(err, response)
		)
	
	flushNameSpace: (ns, ts = null, cb) ->
		if ts?
			@flush(ns, cb)
		else
			@flush(MemcacheAdapter.hashSync(ns), cb)
		