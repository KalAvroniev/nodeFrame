exports.config = require('./global').config

exports.config.memcache =
	ips		: ['192.168.10.42:11211']
	options	: 
		maxExpiration	: 2592000
		poolSize		: 1000
			
exports.config.flush = 'all'
#exports.config.flush = ['/modules/home']

exports.config.sql =
	type: 'mysql'
	host: '192.168.10.44'
	user: 'parklings_com'
	pass: 'p4rkl1ngs'
	db	: ''
	
exports.config.mail =
	from: 'andrew.chinn@wingedmedia.com'
	to	: ['kaloyan.avroniev@wingedmedia.com']
	
exports.config.sms = ['61412188969']

exports.config.apis =
	exchange: 'staging.api.protrada.com:8080'
	user	: 'staging.user.mashhub.com:8080'
	runner	: 'staging.runner.mashhub.com:80'	

exports.config.aws = 
	accessKeyId     : 'AKIAI654DO6KCXT5K54A'
	secretAccessKey : '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'
	bucket			: 'config-bucket-test'