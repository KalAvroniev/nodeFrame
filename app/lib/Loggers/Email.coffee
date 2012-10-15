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
		@ses = new Ses(
			'accessKeyId'     : 'AKIAI654DO6KCXT5K54A'
			'secretAccessKey' : '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'
		)
		
	log: (level, msg, meta, callback) ->
		data = 
			ToAddresses : app.config.mail.to
			Text : msg
			Html : '<p>' + msg + '</p>'
			Subject : level.charAt(0).toUpperCase() + level.substr(1) + ' status in ' + path.basename(path.resolve(__dirname + '/../../../'))
			Source : app.config.mail.from

		@ses.SendEmail(data, (err, data) ->
			if err
				callback(err)
			else
				callback(null, true)
		)