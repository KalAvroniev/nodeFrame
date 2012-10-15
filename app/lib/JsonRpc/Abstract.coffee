crypto = require('crypto')
http = require('http')

class JsonRpcAbstractRequest
	module.exports = @

	constructor: (@url, method, params, @callback) ->
		@call = @format(method, params)

	# Format the call to be a valid jsonrpc 2.0 
	format: (method, params) ->
		return {
			'jsonrpc': '2.0'
			'method': method
			'params': params
			'id': crypto.createHash('md5').update(@url + @path + '/' + method + '?' + params).digest('hex')
		}
		
	validate: (obj, success) ->
		# run success handler
		success()

	send: (error, result) ->