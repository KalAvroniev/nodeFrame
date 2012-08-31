exports.config = 
		appDir: __dirname + "/../../app"
		pubDir: __dirname + "/../../public"
		cacheDir: __dirname + "/../../cache"
		cdn: 
			domain: 'protrada.cachefly.net/v3'
			hostname: 'localhost'
			port: 8181
		cache: true
		cacheStore: ['memcache', 'file']
		service: 'protrada'
		apis:
			exchange: 'api.protrada.com:8080'
			user: 'user.mashhub.com:8080'