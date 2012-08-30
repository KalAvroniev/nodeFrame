exports.config = require('./global.coffee').config

exports.config.database =
		'host': '127.0.0.1'
		'user': 'parklings_com'
		'pass': 'p4rkl1ngs'
		'port': 3306
		
exports.config.memcache =
		ips: ['192.168.10.42:11211']
		options: 
			maxExpiration: 0
			poolSize: 1000
			
exports.config.flush = 'all'
#exports.config.flush = ['/modules/home']