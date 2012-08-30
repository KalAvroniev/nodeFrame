crypto = require('crypto')
FileStore = require('./FileStore.coffee')
failover = new FileStore()

class MemcacheStore
	module.exports = @
		
	tag: (key, tag) ->
		key = tag + '/' + key
		
	@hash: (key) ->
		key = crypto.createHash('md5').update(key).digest('hex')
	
	hashTag: (key, tag) ->
		@tag(MemcacheStore.hash(key), tag)
		
	read: (key, cb) ->
		app.options.memcache.get(key, (err, res) ->
			if err
				failover.read(key, cb)
			else if not res
				cb(true)
			else
				cb(err, res)			
		)
	
	@static_read: (key, cb) ->
		app.options.memcache.get(key, (err, res) ->
			if err
				FileStore.static_read(key, cb)
			else if not res
				cb(true)
			else
				cb(err, res)			
		)
	
	write: (key, value, cb, expire = 0) -> 
		app.options.memcache.replace(key, value, expire, (err, res) ->
			if err
				failover.write(key, value, cb, expire)
			else if not res
				app.options.memcache.set(key, value, expire, (err, res) ->
					if err
						failover.write(key, value, cb, expire)
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
				failover.flush(key, cb)
			else if not res
				cb(true)
			else
				cb(err)
		)
		
	getNameSpace: (ns, cb) ->
		MemcacheStore.static_read(MemcacheStore.hash(ns), cb)
		
	setNameSpace: (ns, cb, res) ->
		date = new Date()
		ts = String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)
		@write(MemcacheStore.hash(ns), ts, (err) ->
			if not err
				cb(ns, (err, data) ->
						res(err, data)
				)
		)
	
	flushNameSpace: (ns, cb) ->
		@flush(MemcacheStore.hash(ns), cb)