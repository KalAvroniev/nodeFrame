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
		app.options.cache.getNameSpace(url, (err, data) =>
			if err
				app.options.cache.setNameSpace(url, app.options.cache.cs.getNameSpace, (err, data) =>
					if not err
						@namespace = data
						@ready(req, url)
					else
						@ready(req, url)
				)
			else
				@namespace = data
				@ready(req, url)
		)
		
	modMasterParams: (params) ->
		@params[key] = val for key, val of params
					
	getDataFromCache: (url, expire, cb) ->
		app.options.cache.read(url, (err, data, change) ->
				if err
					cb(err)
				else
					cb(undefined, JSON.parse(data))
			, expire
		)

	setDataToCache: (url, content, expire) ->
		app.options.cache.write(url
			, JSON.stringify(content)
			, (err, data, change) ->
				if err
					console.error("Data cache could not be saved: " + err)
				else
					console.log("Data cache saved.")
			, expire
		)	
		
	delDataFromCache: (ns) ->
		app.options.cache.flushNameSpace(ns, (err, data, change) =>
			if not err 
				console.log(ns + " cache data deleted.")
		)
		
	render: (cb) ->
	
	ready: (req, index) ->
		url = index
		if @namespace?
			index = app.options.cache.hashTag(index, @namespace)
			@getDataFromCache(index, @params.expires, (err, content) =>
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
		else
			@render(req, (err, content) ->
				return req.next(err) if err
				req.success(content)
			)
