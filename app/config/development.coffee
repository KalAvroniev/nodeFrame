exports.config = require('./global.coffee').config

exports.config.database =
	'host': 'development-db'
	'user': 'parklings_com'
	'pass': 'p4rkl1ngs'
	'port': 3306
		
exports.config.memcache =
	ips: ['192.168.10.42:11211']
	options: 
		maxExpiration: 0
		poolSize: 1000
