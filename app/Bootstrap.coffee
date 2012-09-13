util = require('util')
express = require('express')
everyauth = require('everyauth')
fs	 = require('fs')
jade = require('jade')
path_module = require('path')
memcached = require('memcached')
modules = require('../modules')
cronJob = require('cron').CronJob
DBWrapper = require('node-dbi').DBWrapper
	
class Bootstrap
	module.exports = @
	
	constructor: (@options = {}) ->
		@modules = {}
		@config = {}
	
	start: () ->		
		@loadConfig(@options.config)
		
		#register all modules
		modules.registerModules(__dirname + '/lib', @modules)
		modules.registerModules(__dirname + '/', @modules)
		
		everyauth.debug = true
		
		@usersById = {}
		@nextUserId = 0		
			
		usersByLogin = "protrada": @addUser(
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
				usersByLogin[login] = addUser(newUserAttrs)
			)
			.loginSuccessRedirect("/home")
			.registerSuccessRedirect("/home")
			
		@app = express()
		
		@app.use(express.bodyParser())
		@app.use(express.methodOverride())
		
		@app.use(express.static(@config.pubDir))
		
		@app.use(express.cookieParser())
		@app.use(express.session(
			'secret': 'protrada'
			'maxAge': 1209600000
		))
		@app.use(express.errorHandler())
		@app.use(express.favicon())
		@app.use(@preEveryauthMiddlewareHack())
		@app.use(everyauth.middleware())
		@app.use(@postEveryauthMiddlewareHack())
		
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

			new cronJob('*/10 * * * * *'
				, () => 
					@options.cache.cacheCheck()
				, null
				, true
				, 'Australia/Sydney'
			)
		@options.cache = new @modules.lib.CacheStore
			
		@registerControllers()
		@deleteMinified(@config.pubDir + '/js/require')

		# register JSON-RPC methods must be before the bodyParser
		@jsonRpcServer = new @modules.lib.JsonRpcServer()
		@jsonRpcServer.registerMethods()

		@app.post('/jsonrpc', (req, res) =>
			@jsonRpcServer.handleRequest(req, res)
		)
		
		@app.configure( =>
			@app.set("view engine", "jade")
			@app.set("views", @config.appDir + "/views")
			@app.set('view options', { pretty: true })
		)
		
		@app.use(@app.router)
		
		server = @app.listen(@options.port)
		console.log("Server started on port " + @options.port + ".")
		
		# setup socket.io
		socketIoServer = new @modules.lib.SocketIoServer()
		socketIoServer.setJsonRpcServer(@jsonRpcServer)
		io = require('socket.io').listen(server)
		io.sockets.on('connection', (socket) ->
			socketIoServer.addClient(socket)
		)
		
	@realUrl: (url) ->
		if url.indexOf('?') >= 0
			url = url.substr(0, url.indexOf('?'))

		url = url.replace(/\/+$/, '')
		if url == ''
			url = '/login'
		return url
		
	realPath: (path, cb) ->
		controller = @config.appDir + "/controllers/modules" + path
		fs.stat(controller + ".coffee", (err, stat) =>
			if err
				controller += '/index'
			controller += '.coffee'
			cb(path, controller)
		)
		
	getController: (path) ->
		controller = @modules
		path = path_module.resolve(path)
		ext = path_module.extname(path)
		module = path_module.basename(path, ext)
		path = path_module.dirname(path)				
		folders = path.split(path_module.sep)
		start = folders.indexOf('app')
		if start >= 0
			for i in [++start..folders.length - 1]
				controller = controller[folders[i]]
			return controller[module]
		else
			return false				

	handleJadeRequest: (req, res) ->
		url = __dirname + '/views/modules' + Bootstrap.realUrl(req.url)
		
		console.log(url)
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

	handleRequest: (req, res) =>
		url = Bootstrap.realUrl(req.url)
		# run
		@realPath(url, (url, path) =>
			controller = @getController(path)
			if controller
				controller = new controller
				res.view = {}
				controller.run(req, res, url)
		)

	registerControllers: (path = __dirname + '/controllers/modules') ->
		if path == __dirname + '/controllers/modules'
			console.log("Registering Controllers...")
			@app.all('/', @handleRequest)

		# read the directory
		try
			files = fs.readdirSync(path)
			files.forEach((file) =>
				if file.substr(0, 1) != '.'
					@registerControllers(path + '/' + file)
			)
		catch e
			ext = path_module.extname(path)
			controller = path.replace(/.*?controllers\/modules/, '').replace(ext, '')			
			dest = path_module.basename(controller, ext)
			if dest == 'index'
				controller = path_module.dirname(controller)
			console.log("Registering controller '" + controller + "'")
			@app.all(controller, @handleRequest)
			@app.all(controller + ".jade", @handleJadeRequest)
			@flushCache(controller)
			
	flushCache: (url) ->
		if @config.flush? and (@config.flush == 'all' or url in @config.flush)
			controller = @modules
			@realPath(url, (url, path) =>
				controller = @getController(path)
				if controller
					controller = new controller
					controller.delPageFromCache(url)		
			)

	loadConfig: (config) ->
		@config = require('./config/' + config + '.coffee').config

	deleteMinified: (path) ->
		#read the directory
		try
			files = fs.readdirSync(path)
			files.forEach((file) =>
				if file.substr(0, 1) != '.'
					@deleteMinified(path + '/' + file)
			)
		catch e
			console.log('Now deleting ' + path)
			if (fs.statSync(path).isFile())
				fs.unlinkSync(path)
			else 
				fs.rmdirSync(path)
		
	addUser: (source, sourceUser) ->
		user = undefined
		if arguments.length is 1 # password-based
			user = sourceUser = source
			user.id = ++@nextUserId
			return @usersById[@nextUserId] = user
		else # non-password-based
			user = @usersById[++@nextUserId] = id: @nextUserId
			user[source] = sourceUser
		user
		
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
