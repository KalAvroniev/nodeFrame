class Controller
	module.exports = @
	
	constructor: () ->
		@params = 
			'expires': 60
			'cache': true
		@namespace = ''
		@view = ''

	# Prepare the controller
	run: (req, res, url) ->
		@defaultView(url)
		res.renderView = @view		
		res.view[key] = val for key, val of @params	
		
		if @params.cache
			#namespace
			app.options.cache.getNameSpace(res.renderView, (err, data) =>
				if err
					app.options.cache.setNameSpace(res.renderView, app.options.cache.cs.getNameSpace, (err, data) =>
						if not err
							@namespace = data
							@ready(req, res, req.url)
						else
							@ready(req, res, req.url)
					)
				else
					@namespace = data
					@ready(req, res, req.url)
			)
		else
			@ready(req, res, req.url)
		
	# Set up the view
	defaultView: (url) ->
		if @view == ''
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
		@defaultView(ns)
		app.options.cache.flushNameSpace(@view, (err, data, change) =>
			if not err 
				app.logger(@view + " cache data deleted.")
		)
		
	# Send back to requestor
	ready: (req, res, index) ->
		url = index
		if @namespace != ''
			index = app.options.cache.hashTagSync(index, @namespace)
			@getPageFromCache(index, res.view.expires, (err, content) =>
				if content
					app.logger("Page cache used.")
					res.send(content)
				else
					res.render(res.renderView, res.view , (err, content) =>
						return req.next(err) if err
						try
							@setPageToCache(index, content, res.view.expires)
						catch err
							# maybe initiate a cache failover
						res.send(content)
					)
			)
		else
			res.render(res.renderView, res.view , (err, content) ->
				return req.next(err) if err
				res.send(content)
			)
