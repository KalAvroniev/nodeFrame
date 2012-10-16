http = require('http')

class JsonRpcExternalRequest extends app.modules.lib.JsonRpc.Abstract
	module.exports = @

	constructor: (@url, method, params, @callback) ->
		@path = '/jsonrpc'
		@headers = {}
		super
		
	validate: (obj, success) ->
		super

	send: () ->		
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
					data = JSON.parse(chunk)
					if data.error?
						throw new app.error(@url + @path + '/' + @call.method + ' | ' +data.error.message, @, 'error', data.error.code)
				catch err
					return req.emit('error', err)
				@callback(null, chunk)
			)
			
		)
		
		# On error
		req.on('error', (err) =>
			@callback(err)
		)
		
		# Send data
		req.write(JSON.stringify(@call));
		req.end();