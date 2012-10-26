winston = require('winston')
path = require('path')
awssum = require('awssum')
amazon = awssum.load('amazon/amazon')
Ses = awssum.load('amazon/ses').Ses

class EmailLogger extends winston.Transport
	module.exports = @
	
	constructor: (options) ->
		@name = 'emailLogger'
		@level = if options.level? then options.level else 'error'
		@ses = new Ses(app.config.aws)
		
	log: (level, msg, meta, callback) ->
		data = 
			ToAddresses : app.config.mail.to
			Text : msg
			Html : '<p>' + msg + '</p>'
			Subject : level.charAt(0).toUpperCase() + level.substr(1) + ' status in ' + app.config.service
			Source : app.config.mail.from

		@ses.SendEmail(data, (err, data) ->
			if err
				callback(err)
			else
				callback(null, true)
		)