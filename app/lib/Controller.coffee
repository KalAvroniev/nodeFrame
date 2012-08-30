Store = new (if app.config.store is 'memcache' then require('./MemcacheStore.coffee') else require('./FileStore.coffee'))
crypto = require('crypto')

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
		Store.getNameSpace(res.renderView, (err, data) =>
			if err
				Store.setNameSpace(res.renderView, Store.getNameSpace, (err, data) =>
					if not err
						@namespace = data
						@ready(req, res, req.url)
				)
			else
				@namespace = data
				@ready(req, res, req.url)
		)
		
	defaultView: (url) ->
		if @view == ''
			@view = url.substr(1)
			
	modMasterParams: (params) ->
		@params[key] = val for key, val of params
		
	getPageFromCache: (url, cb) ->
		Store.read(url, (err, data) ->
			if err
				cb(err)
			else
				cb(undefined, data)
		)

	setPageToCache: (url, content, expire) ->
		Store.write(url
			, content
			, (err) ->
				if err
					console.error("Page cache could not be saved: " + err)
				else
					console.log("Page cache saved.")
			, expire
		)	
		
	delPageFromCache: (ns) ->
		@defaultView(ns)
		Store.flushNameSpace(@view, (err) =>
			if not err 
				console.log(@view + " cache data deleted.")
		)
		
	ready: (req, res, index) ->
		index = Store.hashTag(index, @namespace)
		@getPageFromCache(index, (err, content) =>
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
			
