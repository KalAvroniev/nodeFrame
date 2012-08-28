

class MemcacheStore
	module.exports = @
	
	read: (key, cb) ->
		app.options.memcache.get(key, cb)
	
	write: (key, value, cb, expire = 0) -> 
		app.options.memcache.replace(key, value, (err) ->
			if err
				app.options.memcache.set(key, value, exptime: expire, cb)
			else
				cb(err)
			return
		)