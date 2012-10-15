util = require('util')
express = require('express')
everyauth = require('everyauth')
fs	 = require('fs')
jade = require('jade')
path_module = require('path')
memcached = require('memcached')
async = require('async')
modules = require('../modules')
cronJob = require('cron').CronJob
DBWrapper = require('node-dbi').DBWrapper
	
class Bootstrap
	module.exports = @
	
	constructor: (@options = {}) ->
		@modules = {}
		@config = {}
		@usersById = {}
		@nextUserId = 0	
		@jsonRpcServer = @logger = @error = null

	start: () ->		
		everyauth.debug = true	
			
		usersByLogin = "protrada": @addUserSync(
			login: "protrada"
			password: "test"
		)
		
		everyauth.everymodule.findUserById (id, callback) =>
			callback null, @usersById[id]
			
		everyauth.everymodule.logoutRedirectPath('/login');
			
		everyauth.everymodule.handleLogout (req, res) ->
			req.logout()
			@redirect(res, @logoutRedirectPath())

		everyauth.password
			#.loginWith("email")
			.getLoginPath("/login")
			.postLoginPath("/login")
			.loginView("login")
			.loginLocals((req, res, done) ->
				setTimeout (->
					done null,
						title: "Async login"

				), 200
			)
			.authenticate((login, password) ->
				errors = []
				errors.push "Missing login"	unless login
				errors.push "Missing password"	unless password
				return errors	if errors.length
				user = usersByLogin[login]
				return ["Login failed"]	unless user
				return ["Login failed"]	if user.password isnt password
				user
			)
			.getRegisterPath("/register")
			.postRegisterPath("/register")
			.registerView("register.jade")
			.registerLocals((req, res, done) ->
				setTimeout (->
					done null,
						title: "Async Register"

				), 200
			)
			.validateRegistration((newUserAttrs, errors) ->
				login = newUserAttrs.login
				errors.push "Login already taken"	if usersByLogin[login]
				errors
			)
			.registerUser((newUserAttrs) ->
				login = newUserAttrs[@loginKey()]
				usersByLogin[login] = addUserSync(newUserAttrs)
			)
			.loginSuccessRedirect("/home")
			.registerSuccessRedirect("/home")
			
		@app = express()
		
		@app.use(express.bodyParser())
		@app.use(express.methodOverride())
		
		@app.use(express.cookieParser())
		@app.use(express.session(
			'secret': 'protrada'
			'maxAge': 1209600000
		))
		@app.use(express.favicon())
		@app.use(@preEveryauthMiddlewareHack())
		@app.use(everyauth.middleware())
		@app.use(@postEveryauthMiddlewareHack())
		
		async.auto(
				config: (callback) =>
					try
						@loadConfigSync(@options.config)
						callback()
					catch err
						callback(err)
				modules: ['config', (callback) =>
					try
						#register all modules
						modules.registerModulesSync(__dirname + '/lib', @modules)
						modules.registerModulesSync(__dirname + '/', @modules)	
						@logger = @modules.lib.ErrorHandler.appLoggerSync
						@error  = @modules.lib.ErrorHandler.appError
						callback()
					catch err
						callback(err)
				]
				cache: ['modules', (callback) =>
					# setup cache
					if @config.cache.enabled
						if 'memcache' in @config.cache.stores 
							@options.memcache = new memcached(@config.memcache.ips, @config.memcache.options)		

						if 'db' in @config.cache.stores
							dbConfig = 
								host: app.config.sql.host
								user: app.config.sql.user
								password: app.config.sql.pass
								database: 'cache'
							@options.dbcache = new DBWrapper(@config.sql.type, dbConfig)

						new cronJob('* * * * * *'
							, () => 
								@options.cache.cacheCheck()
							, null
							, true
							, 'Australia/Sydney'
						)
					try 
						@options.cache = new @modules.lib.CacheStore
						callback()
					catch err
						callback(err)
				]
				register_controllers: ['modules', (callback) =>
					try
						@registerControllers()
						callback()
					catch err
						callback err
				]
				clear_minified: ['modules', (callback) =>
					try
						@deleteMinifiedSync(@config.pubDir + '/js/require')
						callback()
					catch err
						callback(err)
				]
				clear_api_cache: ['modules', (callback) =>
					@jsonRpcServer = new @modules.lib.JsonRpc.Server()
					@jsonRpcServer.flushingCache()
					callback()
				]
			, (err, result) =>
				if err
					console.log(err)
					#throw @logger(err, 'fatal')
		)		

		@app.post('/jsonrpc', (req, res) =>
			@jsonRpcServer.handleRequest(req, res)
		)
		
		@app.configure( =>
			@app.set("view engine", "jade")
			@app.set("views", @config.appDir + "/views")
			@app.set('view options', { pretty: true })
		)
		
		@app.use(express.static(@config.pubDir))
		@app.use(@app.router)
		#@app.use(@modules.lib.ErrorHandler.errorHandler)
		#@app.use(Bootstrap.errorHandler)
		
		server = @app.listen(@options.port)
		console.log("Server started on port " + @options.port + ".")
		
		# setup socket.io
		socketIoServer = new @modules.lib.SocketIoServer()
		socketIoServer.setJsonRpcServer(@jsonRpcServer)
		io = require('socket.io').listen(server)
		io.sockets.on('connection', (socket) ->
			socketIoServer.addClient(socket)
		)
		
	# Return stripped out url without parameters
	@realUrlSync: (url, loggedIn=false) ->
		if url.indexOf('?') >= 0
			url = url.substr(0, url.indexOf('?'))

		url = url.replace(/\/+$/, '')
		if url == ''
			if loggedIn
				url = '/home'
			else
				url = '/login'
		
		return url
		
	# Mainly used to convert the url to a coffee/js file and return the file path
	realPath: (path, cb) ->
		controller = @config.appDir + "/controllers/modules" + path
		fs.stat(controller + '.coffee', (err, stat) ->
			if err
				fs.stat(controller + '/index.coffee', (err, stat) ->
					if err
						fs.stat(controller + '.js', (err, stat) ->
							if err
								controller += '/index.js'
							else
								controller += '.js'
							
							cb(null, path, controller)
						)
					else
						controller += '/index.coffee'
						cb(null, path, controller)
				)
			else
				controller += '.coffee'
				cb(null, path, controller)
		)
		
	# Find and return a controller basd on path
	getControllerSync: (path) ->
		try
			controller = @modules
			path = path_module.resolve(path)
			ext = path_module.extname(path)
			module = path_module.basename(path, ext)
			path = path_module.dirname(path)				
			folders = path.split(path_module.sep)
			start = if process.env.COVERAGE then folders.indexOf('app-cov') else folders.indexOf('app')
			if start >= 0
				for i in [++start..folders.length - 1]
					controller = controller[folders[i]]
				return controller[module]
		catch err
			throw @logger(err, 'fatal')

	# The middleware that handles all .jade requests
	handleJadeRequestSync: (req, res) ->
		url = __dirname + '/views/modules' + Bootstrap.realUrlSync(req.url, res.locals.everyauth.loggedIn)		
		# fetch the raw jade
		fs.readFile(url, 'utf8', (err, data) ->
			if err
				res.write(err)
			else
				# compile the jade
				jc = jade.compile(data, { client: true, filename: url, debug: false, compileDebug: true }).toString()
				fn = url.replace(/^.*?app\//, '').replace(/\.jade$/, '').replace(/[\/-]/g, '_')
				res.write('document.' + fn + ' = ' + jc)

			res.end()
		)

	# The middleware that handles all app urls
	handleRequestSync: (req, res) =>
		url = Bootstrap.realUrlSync(req.url, res.locals.everyauth.loggedIn)
		# need a better handler for / when logged in and when not
		if url == '/login'	
			res.redirect('/login')		
			return
		
		# run
		@realPath(url, (err, url, path) =>
			if not err 
				controller = @getControllerSync(path)
				if controller
					controller = new controller
					res.view = {}
					controller.run(req, res, url)
		)

	# This functions configures all the routes based on the controller modules	
	registerControllers: (path = __dirname + '/controllers/modules', queue = null) ->
		if queue == null
			queue = async.queue((path, callback) =>
					fs.stat(path, (err, stat) =>
						if not err
							if stat.isDirectory()
								@registerControllers(path, queue)
							else
								ext = path_module.extname(path)
								controller = path.replace(/.*?controllers\/modules/, '').replace(ext, '')			
								dest = path_module.basename(controller, ext)
								if dest == 'index'
									controller = path_module.dirname(controller)
								@logger("Registering route '" + controller + "'")
								@app.all(controller, @handleRequestSync)
								@app.all(controller + ".jade", @handleJadeRequestSync)
								@flushCacheSync(controller)								
					)
					callback()
				, 10
			)
	
		if path == __dirname + '/controllers/modules'
			@logger("Registering Routes ...")
			@app.all('/', @handleRequestSync)

		# read the directory
		fs.readdir(path, (err, files) =>
			if not err
				files.forEach((file) =>
					if file.substr(0, 1) != '.'
						queue.push(path + '/' + file, (err) =>
							if err
								throw @logger(err, 'fatal')
						)
				)
		)
			
	# Handles cache flushing based on configuration/modified controllers
	flushCacheSync: (url) ->
		if @config.flush? and (@config.flush == 'all' or url in @config.flush)
			controller = @modules
			@realPath(url, (err, url, path) =>
				if not err
					controller = @getControllerSync(path)
					if controller
						controller = new controller
						controller.delPageFromCache(url)		
			)

	# Loads the application configuration
	loadConfigSync: (config) ->
		@config = require('./config/' + config).config

	# Deletes any minified javasript	
	deleteMinifiedSync: (path) ->
		#read the directory
		try
			files = fs.readdirSync(path)
			files.forEach((file) =>
				if file.substr(0, 1) != '.'
					@deleteMinifiedSync(path + '/' + file)
			)
		catch e
			@logger('Now deleting ' + path)
			if (fs.statSync(path).isFile())
				fs.unlinkSync(path)
			else 
				fs.rmdirSync(path)
		
	addUserSync: (source, sourceUser) ->
		user = undefined
		if arguments.length is 1 # password-based
			user = sourceUser = source
			user.id = ++@nextUserId
			return @usersById[@nextUserId] = user
		else # non-password-based
			user = @usersById[++@nextUserId] = id: @nextUserId
			user[source] = sourceUser
			
		return user
		
	preEveryauthMiddlewareHack: ->
		(req, res, next) ->
			sess = req.session
			auth = sess.auth
			ea = loggedIn: !!(auth and auth.loggedIn)

			# Copy the session.auth properties over
			for k of auth
				ea[k] = auth[k]
			if everyauth.enabled.password

				# Add in access to loginFormFieldName() + passwordFormFieldName()
				ea.password or (ea.password = {})
				ea.password.loginFormFieldName = everyauth.password.loginFormFieldName()
				ea.password.passwordFormFieldName = everyauth.password.passwordFormFieldName()
				res.locals.everyauth = ea
			next()

	postEveryauthMiddlewareHack: ->
		userAlias = everyauth.expressHelperUserAlias or "user"
		(req, res, next) ->
			res.locals.everyauth.user = req.user
			res.locals[userAlias] = req.user
			next()