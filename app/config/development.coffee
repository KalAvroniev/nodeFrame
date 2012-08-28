exports.config = require('./global.coffee').config

exports.config.database =
		'host': 'development-db'
		'user': 'parklings_com'
		'pass': 'p4rkl1ngs'
		'port': 3306
		
exports.config.memcache =
		'ip': 'backupdev:11211'
