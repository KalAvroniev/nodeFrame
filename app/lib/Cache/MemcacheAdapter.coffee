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
			if err
				cb(err, res, true)
			else if not res
				app.options.memcache.set(key, value, expire, (err, res) ->
					if err
						cb(err, res, true)
					else if not res
						cb(true)
					else
						cb(err)					
				)
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
		
	getNameSpace: (ns, cb) ->
		MemcacheAdapter.static_read(MemcacheAdapter.hashSync(ns), 0, cb)
		
	setNameSpace: (ns, cb, res) ->
		date = new Date()
		ts = String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)
		@write(MemcacheAdapter.hashSync(ns), ts, 0, (err, response) ->
			if not err
				cb(ns, res)
			else
				res(err, response)
		)
	
	flushNameSpace: (ns, cb) ->
		@flush(MemcacheAdapter.hashSync(ns), cb)