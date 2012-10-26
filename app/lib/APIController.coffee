URL = require('url')

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
		full_url = URL.format(
			hostname: url
			query: req.request.call.params
		).replace('//', '')
		if @params.cache 
			#namespace
			app.options.cache.getNameSpace(url, null, (err, data) =>
				if err
					app.options.cache.setNameSpace(url, null, app.options.cache.cs.getNameSpace, (err, data) =>
						if not err
							@namespace = data
							@ready(req, full_url)
							setTimeout(() =>
									@updateNamespaceConfig(url)
								, Math.round(Math.random()*60)*1000)
						else
							@ready(req, full_url)
					)
				else
					@namespace = data
					@ready(req, full_url)
			)
		else
			@ready(req, full_url)
		
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
		app.options.cache.flushNameSpace(ns, null, (err, data, change) ->
			if not err 
				app.logger(ns + " cache data deleted.")
		)
		
	# Render the page with all its content and views
	render: (req, cb) ->
	
	# Add cache information
	cacheInfo: (content) ->
		content.expires = @params.expires
		content.cache	  = @params.cache
		return content
	
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
							@setDataToCache(index, @cacheInfo(content), @params.expires)
						catch err
							req.send(err)
						
						req.send(err, @cacheInfo(content))
					)
				else 
					app.logger("Data cache used.")
					req.send(err, @cacheInfo(content))
			)
		else
			@render(req, (err, content) =>
				#return req.next(err)
				return req.send(err) if err
				req.send(err, @cacheInfo(content))
			)
			
	# store the namespace in a global configuration file
	updateNamespaceConfig: (index) ->
		cc = new app.modules.lib.CacheConfig()
		cc.read(app.config.service, null, (err, data) =>
			if err
				data = {}
			else
				data = JSON.parse(data)
			data[app.options.cache.CS.hashSync(index)] = @namespace
			cc.write(app.config.service, JSON.stringify(data), (err, data) ->
				if err
					app.logger(err, 'error')
			)
		)
