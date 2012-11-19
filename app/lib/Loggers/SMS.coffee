winston = require('winston')
path = require('path')

class SMSLogger extends winston.Transport
	module.exports = @
	
	constructor: (options) ->
		@name = 'smsLogger'
		@level = if options.level? then options.level else 'fatal'
		
	log: (level, msg, meta, callback) ->
		try
			request = new app.modules.lib.JsonRpc.Request()
			app.config.sms.forEach((number) ->
				data = 
					to	: number
					text: msg
					from: app.config.service

				request.add('runner', 'clickatell/send-message', data, (err, id, res) ->
					if err 
						#retry individually on error
						call = request.getRequestById(id)
						call.retry(err, id, res)
				)
			)	

			request.send()
		catch err
			#do nothing
		callback(null, true)