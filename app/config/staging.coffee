exports.config = require('./global.coffee').config

exports.config.database =
		'host': '127.0.0.1'
		'user': 'parklings_com'
		'pass': 'p4rkl1ngs'
		'port': 3306
		
exports.config.memcache =
		'ip': 'backupdev:11211'