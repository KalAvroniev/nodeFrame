winston = require('winston')
path = require('path')

class SMSLogger extends winston.Transport
	module.exports = @
	
	constructor: (options) ->
		@name = 'smsLogger'
		@level = if options.level? then options.level else 'fatal'
		
	log: (level, msg, meta, callback) ->
		app.config.sms.forEach((number) ->
			data = 
				to:		number
				text: msg
				from: path.basename(path.resolve(__dirname + '/../../../'))

			error = new app.modules.lib.JsonRpc.Request('runner', 'clickatell/send-message', data, (err, res) ->)
			
			error.send()
		)