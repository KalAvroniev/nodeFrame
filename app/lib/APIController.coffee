URL		= require('url')
async	= require('async')

class APIController
	module.exports = @
	
	constructor: () ->
		@params 	= 
			'expires': 60
			'cache': true
		@validate 	= {}
		@options 	= {}
		@namespace 	= @id = @needed_res = null
		
	# Check if server has resources
	checkResourcesAndRun: (req, url) ->
		@id 			= app.options.cache.CS.hashSync(url)
		@assignResources((err, execute) =>
			if execute
				@run(req, url)
			else
				process.nextTick(() =>
					@checkResourcesAndRun(req, url)
					app.logger(new app.error('No resources available for this controller', @, 'error'))
				)		
		)

	# Prepare the controller
	run: (req, url) ->	
		full_url 	= URL.format(
			hostname: url
			query: req.request.call.params
		).replace('//', '')
		
		async.waterfall([
				(callback) =>
					if @params.cache 
						#namespace
						app.options.cache.getNameSpace(url, null, (err, data) =>
							if err
								app.options.cache.setNameSpace(url, null, app.options.cache.cs.getNameSpace, (err, data) =>
									if not err
										@namespace = data
										setTimeout(() =>
												@updateNamespaceConfig(url)
											, Math.round(Math.random()*60)*1000)
									
									callback(null, req, full_url)
								)
							else
								@namespace = data
								callback(null, req, full_url)
						)
					else
						callback(null, req, full_url)
				, (req, url, callback) =>
					@ready(req, url)
					callback()
			], (err, result) ->
				return app.logger(err, 'error') if err
		)
		
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
		content.cache 	= @params.cache
		return content
	
	# Send back to requestor
	ready: (req, index) ->
		if @namespace?
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
			
		@releaseResourcesSync()
			
	# store the namespace in a global configuration file
	updateNamespaceConfig: (index) ->
		if not app.options.cc?
			app.options.cc = new app.modules.lib.CacheConfig()
		app.options.cc.read(app.config.service, null, (err, data) =>
			if err
				data = {}
			else
				data = JSON.parse(data)
			data[app.options.cache.CS.hashSync(index)] = @namespace
			app.options.cc.write(app.config.service, JSON.stringify(data), (err, data) ->
				if err
					app.logger(err, 'error')
			)
		)
		
	assignResources: (cb) ->
		app.profiler.storage.read(@id, (err, res) =>
			return cb(err) if err
			@needed_res = res
			execute = true
			if @needed_res?
				app.config.resources.cpu -= @needed_res.cpu
				if app.config.resources.cpu < 0
					execute = false 

				app.config.resources.memory -= @needed_res.memory
				if app.config.resources.memory < 0
					execute = false 

				if not execute
					@releaseResourcesSync()
				
			return cb(null, execute)
		)
	
	releaseResourcesSync: () ->
		if @needed_res?
			app.config.resources.cpu	+= @needed_res.cpu
			app.config.resources.memory += @needed_res.memory
