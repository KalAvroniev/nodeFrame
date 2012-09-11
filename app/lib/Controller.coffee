class Controller
	module.exports = @
	
	constructor: () ->
		@params = 
			'expires': 60
		@namespace = ''
		@view = ''

	run: (req, res, url) ->
		@defaultView(url)
		res.renderView = @view
		
		res.view[key] = val for key, val of @params	
		
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
		
	defaultView: (url) ->
		if @view == ''
			@view = 'modules/' + url.substr(1)
			
	modMasterParams: (params) ->
		@params[key] = val for key, val of params
		
	getPageFromCache: (url, expire, cb) ->
		app.options.cache.read(url, (err, data, change) ->
				if err
					cb(err)
				else
					cb(undefined, data)
			, expire
		)

	setPageToCache: (url, content, expire) ->
		app.options.cache.write(url
			, content
			, (err, data, change) ->
				if err
					console.error("Page cache could not be saved: " + err)
				else
					console.log("Page cache saved.")
			, expire
		)	
		
	delPageFromCache: (ns) ->
		@defaultView(ns)
		app.options.cache.flushNameSpace(@view, (err, data, change) =>
			if not err 
				console.log(@view + " cache data deleted.")
		)
		
	ready: (req, res, index) ->
		url = index
		if @namespace?
			index = app.options.cache.hashTag(index, @namespace)
			@getPageFromCache(index, res.view.expires, (err, content) =>
				if content
					console.log("Page cache used.")
					res.send(content)
				else
					res.render(res.renderView, res.view , (err, content) =>
						return req.next(err) if err
						@setPageToCache(index, content, res.view.expires)
						res.send(content)
					)
			)
		else
			res.render(res.renderView, res.view , (err, content) ->
				return req.next(err) if err
				res.send(content)
			)
