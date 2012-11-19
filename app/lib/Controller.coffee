async = require('async')

class Controller
	module.exports = @
	
	constructor: () ->
		@params 	= 
			'expires'	: 60
			'cache'		: true
		@namespace	= @view = @id = @needed_res = null
		
	# Check if server has resources
	checkResourcesAndRun: (req, res, url, cb) ->
		service_url 	= app.config.service + url
		@id 			= app.options.cache.CS.hashSync(service_url)
		@assignResources((err, execute) =>
			if execute
				@run(req, res, url, cb)
			else
				process.nextTick(() =>
					@checkResourcesAndRun(req, res, url, cb)
					app.logger(new app.error('No resources available for this controller', @, 'error'))
				)		
		)

	# Prepare the controller
	run: (req, res, url, cb) ->
		@defaultView(url)
		res.renderView 	= @view		
		res.view[key] 	= val for key, val of @params	
		service_url 	= app.config.service + url
		async.waterfall([
				(callback) =>
					if @params.cache
						#namespace
						app.options.cache.getNameSpace(service_url, null, (err, data) =>
							if err
								app.options.cache.setNameSpace(service_url, null, app.options.cache.cs.getNameSpace, (err, data) =>
									if not err
										@namespace = data

									callback(null, req, res, req.url, cb)
								)		
							else
								@namespace = data
								callback(null, req, res, req.url, cb)
						)
					else			
						callback(null, req, res, req.url, cb)
				, (req, res, url, cb, callback) =>
					@ready(req, res, url, cb)
					callback()
			], (err, result) ->
				return app.logger(err, 'error') if err
		)
		
	# Set up the view
	defaultView: (url) ->
		if not @view?
			@view = 'modules/' + url.substr(1)
			
	# Used to overwrite parent parameters
	modMasterParams: (params) ->
		@params[key] = val for key, val of params
		
	# Get data from cache
	getPageFromCache: (url, expire, cb) ->
		app.options.cache.read(url, expire, (err, data, change) ->
			if err
				cb(err)
			else
				cb(undefined, data)
		)

	# Save data to cache
	setPageToCache: (url, content, expire) ->
		app.options.cache.write(url, content, expire, (err, data, change) =>
			if err
				throw app.logger(new app.error("Page cache could not be saved: " + err, @, 'warn'))
			else
				app.logger("Page cache saved.")
		)	
		
	# Delete data from cache
	delPageFromCache: (ns) ->
		#@defaultView(ns)
		app.options.cache.flushNameSpace(ns, null, (err, data, change) ->
			if not err 
				app.logger(ns + " cache data deleted.")
		)
		
	# Send back to requestor
	ready: (req, res, index, cb) ->
		if not @namespace?
			index = app.options.cache.hashTagSync(index, @namespace)
			@getPageFromCache(index, res.view.expires, (err, content) =>
				if content
					app.logger("Page cache used.")
					cb(null, content)
				else
					res.render(res.renderView, res.view , (err, content) =>
						return cb(err) if err
						try
							@setPageToCache(index, content, res.view.expires)
						catch err
							# maybe initiate a cache failover
						cb(null, content)
					)
			)
		else
			res.render(res.renderView, res.view , (err, content) ->
				return cb(err) if err
				cb(null, content)
			)
			
		@releaseResourcesSync()
	
			
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
