http 	= require('http')
URL 	= require('url')
async 	= require('async')

class JsonRpcExternalRequest extends app.modules.lib.JsonRpc.Abstract
	module.exports = @

	constructor: (@service, @url, method, params, @callback) ->
		@path 		= '/jsonrpc'
		@headers 	= 
			'Content-Type': 'application/json'
			'Accept': 		'application/json'

		super(@url, method, params, @callback)
		
	validate: (obj, success) ->
		super 

	send: (error, result) ->	
		return if not super?
		orig_call = app.modules.lib.Functions.clone(@call)
		async.auto(
			cache_check: (callback) =>
				if @call.method == 'bulk'
					@checkBulkCache(@call, (@cache) =>
						callback()
					)
				else
					@checkForCache(@call, (@cache) =>
						callback()
					)
			send: ['cache_check', (callback) =>
					if @call.params instanceof Array and @call.params.length == 0 
						@cache 	= app.modules.lib.JsonRpc.Server.BulkResponse(@call.id, null, @cache)
						@call 	= orig_call
						@callback(null, @call.id, @service, JSON.stringify(@cache))
					else if not @cache instanceof Array and @cache
						@call = orig_call
						@callback(null, @call.id, @service, JSON.stringify(@cache))
					else
						tmp 	= @url.split(':')
						options = 
							'hostname': tmp[0]
							'port': 	tmp[1]
							'path': 	@path
							'method': 	'POST'
							'headers': 	@headers
							'agent': 	http.globalAgent # read http://nodejs.org/api/all.html#all_class_http_agent

						req = http.request(options, (result) =>
							result.setEncoding('utf8');
							result.on('data', (chunk) =>
								try 
									@checkForError(chunk)
								catch err
									return req.emit('error', err)
								if @cache.length > 0
									chunk = JSON.stringify(app.modules.lib.JsonRpc.Server.BulkResponse(@call.id, JSON.parse(chunk), @cache))
								
								@call = orig_call
								@callback(null, @call.id, @service, chunk)
							)			
						)

						# On error
						req.on('error', (err) =>
							@call = orig_call
							@callback(err, @call.id)
						)

						# Send data
						req.write(JSON.stringify(@call))
						req.end()
					
					callback()
				]
			, () ->		
		)
		
	checkForCache: (call, cb) ->
		if app.config.namespaces[@service]?
			#get namespace
			tmp 		= @url.split(':')
			controller 	= URL.format(
				hostname: tmp[0] + @path + '/' + call.method
			).replace('//', '')			
			namespace 	= app.config.namespaces[@service][app.options.cache.CS.hashSync(controller)]
			
			if namespace?
				#look for cache
				full_url = URL.format(
					hostname: tmp[0] + @path + '/' + call.method
					query: call.params
				).replace('//', '')	
				index = app.options.cache.hashTagSync(full_url, namespace)
				@getCache(index, (err, data) =>
					if err
						cache 	= false
					else
						cache 	= app.modules.lib.JsonRpc.Server.Success(call.id, @alreadyCached(data))
						call 	= undefined
					cb(cache)
				)
			else
				cb(false)
		else
			cb(false)
	
	checkBulkCache: (call, cb) ->
		cache 					= []
		no_local_cache_calls 	= []
		counter 				= call.params.length
		if counter > 0
			call.params.forEach((single) =>
				@checkForCache(single, (res) =>
					counter--
					if res
						cache.push(res)
					else
						no_local_cache_calls.push(single)

					if counter <= 0
						call.params = no_local_cache_calls
						cb(cache)
				)
			)
		else
			cb(cache)
		
	# Get cache
	getCache: (index, cb) ->
		app.options.cache.read(index, 1, (err, data, change) ->
			if err
				cb(err)
			else
				cb(null, data)
		)
	
	# Marks the result as cached so that we do not cache it again
	alreadyCached: (content) ->
		content 		= JSON.parse(content)
		content.cache 	= false
		return content