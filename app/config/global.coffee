exports.config = 
		appDir: __dirname + "/../../app"
		pubDir: __dirname + "/../../public"
		cacheDir: __dirname + "/../../cache"
		cdn: 
			domain: 'protrada.cachefly.net/v3'
			hostname: 'localhost'
			port: 8181
		cache:
			enabled: true
			stores: ['memcache', 'db', 'file']
			index: 0
		service: 'protrada'
		apis:
			exchange: 'api.protrada.com:8080'
			user:			'user.mashhub.com:8080'
			runner:		'staging.runner.mashhub.com:80'
		mail:
			host: 'mail.geekhub.com'
			tls: true
			username:	'gsupport'
			password: 'Fatman45'