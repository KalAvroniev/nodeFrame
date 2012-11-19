path = require('path')

exports.config = 
		appDir			: __dirname + "/../../app"
		pubDir			: __dirname + "/../../public"
		cacheDir		: __dirname + "/../../cache"
		cdn				: 
			domain		: 'protrada.cachefly.net/v3'
			hostname	: 'localhost'
			port		: 8181
		cache			:
			enabled		: true
			stores		: ['memcache', 'db', 'file']
			index		: 0
			config		: 's3'
		profiler		: 'mongoDB'
		service			: path.basename(path.resolve(__dirname + '/../../'))
		maxSockets		: 500
		async			:
			name		: 'AsyncSend'
			version		: '2.2'
			getJob		: '2.0'
			sendResult	: '2.0'