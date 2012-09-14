exports.config = require('./global').config

exports.config.memcache =
	ips: ['192.168.10.42:11211']
	options: 
		maxExpiration: 0
		poolSize: 1000
			
exports.config.flush = 'all'
#exports.config.flush = ['/modules/home']

exports.config.sql =
	type: 'mysql'
	host: '192.168.10.44'
	user: 'parklings_com'
	pass: 'p4rkl1ngs'
	db: ''