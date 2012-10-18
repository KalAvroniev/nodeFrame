http = require('http')

class JsonRpcExternalRequest extends app.modules.lib.JsonRpc.Abstract
	module.exports = @

	constructor: (@url, method, params, @callback) ->
		@path = '/jsonrpc'
		@headers = {}
		super
		
	validate: (obj, success) ->
		super

	send: (error, result) ->	
		return if not super?
		tmp = @url.split(':')
		options = 
			'hostname': tmp[0]
			'port': tmp[1]
			'path': @path
			'method': 'POST'
			'headers': @headers
			'agent': http.globalAgent
		
		req = http.request(options, (result) =>
			result.setEncoding('utf8');
			result.on('data', (chunk) =>
				try 
					@checkForError(chunk)
				catch err
					return req.emit('error', err)
				@callback(null, @call.id, chunk)
			)
			
		)
		
		# On error
		req.on('error', (err) =>
			@callback(err, @call.id)
		)
		
		# Send data
		req.write(JSON.stringify(@call));
		req.end();