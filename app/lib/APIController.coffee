Cache = new (require('./CacheStore.coffee'))

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
		Cache.getNameSpace(url, (err, data) =>
			if err
				Cache.setNameSpace(url, Cache.cs.getNameSpace, (err, data) =>
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
		Cache.read(url, (err, data, change) ->
			if err
				cb(err)
			else
				cb(undefined, data)
		)

	setDataToCache: (url, content, expire) ->
		Cache.write(url
			, content
			, (err, data, change) ->
				if err
					console.error("Data cache could not be saved: " + err)
				else
					console.log("Data cache saved.")
			, expire
		)	
		
	delDataFromCache: (ns) ->
		Cache.flushNameSpace(ns, (err, data, change) =>
			if not err 
				console.log(ns + " cache data deleted.")
		)
		
	render: (cb) ->
	
	ready: (req, index) ->
		index = Cache.hashTag(index, @namespace)
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
			
