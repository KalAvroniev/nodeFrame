Store = new (if app.config.store is 'memcache' then require('./MemcacheStore.coffee') else require('./FileStore.coffee'))
crypto = require('crypto')

class APIController
	module.exports = @
	
	constructor: () ->
		@params = 
			'expires': 60
		@validate = {}
		@options = {}
		@namespace = ''

	run: (req, url) ->		
		#namespace
		Store.getNameSpace(url, (err, data) =>
			if err
				Store.setNameSpace(url, Store.getNameSpace, (err, data) =>
					if not err
						@namespace = data
						@ready(req, url)
				)
			else
				@namespace = data
				@ready(req, url)
		)
		
	modMasterParams: (params) ->
		@params[key] = val for key, val of params
					
	getDataFromCache: (url, cb) ->
		Store.read(url, (err, data) ->
			if err
				cb(err)
			else
				cb(undefined, data)
		)

	setDataToCache: (url, content, expire) ->
		Store.write(url
			, content
			, (err) ->
				if err
					console.error("Data cache could not be saved: " + err)
				else
					console.log("Data cache saved.")
			, expire
		)	
		
	delDataFromCache: (ns) ->
		Store.flushNameSpace(ns, (err) =>
			if not err 
				console.log(ns + " cache data deleted.")
		)
		
	render: (cb) ->
	
	ready: (req, index) ->
		index = Store.hashTag(index, @namespace)
		@getDataFromCache(index, (err, content) =>
			if content
				console.log("Data cache used.")
				req.success(content)
			else
				@render(req, (err, content) =>
					return req.next(err) if err
					@setDataToCache(index, content, @params.expires)
					req.success(content)
				)
		)
			
