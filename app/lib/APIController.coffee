class APIController
	module.exports = @
	
	constructor: () ->
		@params = 
			'expires': 60
			'cache': true
		@validate = {}
		@options = {}
		@namespace = ''

	# Prepare the controller
	run: (req, url) ->	
		if @params.cache 
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
		else
			@ready(req, url)
		
	# Used to overwrite parent parameters
	modMasterParams: (params) ->
		@params[key] = val for key, val of params
					
	# Get data from cache
	getDataFromCache: (url, expire, cb) ->
		app.options.cache.read(url, expire, (err, data, change) ->
			if err
				cb(err)
			else
				cb(undefined, JSON.parse(data))
		)

	# Save data to cache
	setDataToCache: (url, content, expire) ->
		app.options.cache.write(url, JSON.stringify(content), expire, (err, data, change) =>
			if err
				app.logger(new app.error("Data cache could not be saved: " + err, @, 'warn'))
			else
				app.logger("Data cache saved.")
		)	
		
	# Delete data from cache
	delDataFromCache: (ns) ->
		app.options.cache.flushNameSpace(ns, (err, data, change) =>
			if not err 
				app.logger(ns + " cache data deleted.")
		)
		
	# Render the page with all its content and views
	render: (req, cb) ->
	
	# Send back to requestor
	ready: (req, index) ->
		if @namespace != ''
			index = app.options.cache.hashTagSync(index, @namespace)
			@getDataFromCache(index, @params.expires, (err, content) =>
				if err
					@render(req, (err, content) =>
						#return req.next(err)
						return req.send(err) if err
						try 
							@setDataToCache(index, content, @params.expires)
						catch err
							req.send(err)
							
						req.send(err, content)
					)
				else 
					app.logger("Data cache used.")
					req.send(err, content)
			)
		else
			@render(req, (err, content) ->
				#return req.next(err)
				return req.send(err) if err
				req.send(err, content)
			)
