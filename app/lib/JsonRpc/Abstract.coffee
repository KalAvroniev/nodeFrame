crypto 	= require('crypto')
URL 	= require('url')

class JsonRpcAbstractRequest
	module.exports = @

	constructor: (@url, method, params, @callback) ->
		@retries 	= 3
		@call 		= @format(method, params)
		
	# Format the call to be a valid jsonrpc 2.0 
	format: (method, params) ->
		tmp = []	
		if @url?
			tmp = @url.split(':')
		else
			tmp[0] = @url
			
		full_url = URL.format(
			hostname: 	tmp[0] + @path + '/' + method
			query: 		params
		).replace('//', '')			
		return {
			'jsonrpc'	: '2.0'
			'method'	: method
			'params'	: params
			'id'		: crypto.createHash('md5').update(full_url).digest('hex')
		}
	
	validate: (obj, success) ->
		# run success handler
		success()
		
	send: (error, result) ->
		switch typeof @callback
			when 'function' # sync case
				@sendSync(error, result)
			when 'object' # async case
				return false
			else
				return false
	
	setRetries: (num) ->
		@retries = num
		
	checkForError: (data) ->
		data = JSON.parse(data)
		if data.error?
			throw new app.error(@url + @path + '/' + @call.method + ' | ' + data.error.message, @, 'error', data.error.code)
			
	sendSync: (error, result) ->
		if error
			# retry only on error
			if @retries == 0 
				app.logger(new app.error('Retry limit reached | ' + error.message, @, 'warn'))
				@callback(error, @call.id, 'Stop')
				return false
			else
				@retries -= 1

		# continue with script
		return true

	sendAsync: () ->
		average_exec_time = '60'
		app.options.swf.connect.StartWorkflowExecution({
				Domain						: app.config.service
				WorkflowId					: '' + Math.floor((Math.random()*10)+1)
				WorkflowType				: 
					name					: app.config.async.name
					version					: app.config.async.version
				ExecutionStartToCloseTimeout: average_exec_time
				TaskStartToCloseTimeout		: average_exec_time	
				ChildPolicy					: 'REQUEST_CANCEL'
				Input						: 'Input as String'
			}
			, (err, res) ->
				console.log('StartWorkflowExecution', err, res)
		)
		