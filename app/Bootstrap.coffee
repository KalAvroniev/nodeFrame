util = require('util')
express = require("express")
everyauth = require("everyauth")
fs	 = require('fs')
jade = require('jade')
path = require('path')
mc = require('mc')
JsonRpcServer = require('./lib/JsonRpcServer.coffee')
SocketIoServer = require('./lib/SocketIoServer.coffee')
	
class Bootstrap
	module.exports = @
		
	socketIoServer = new SocketIoServer()
	
	constructor: (@options = {}) ->
	
	start: () ->
		@loadConfig(@options.config)
		
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
		
		# setup memcache cluster
		@options.memcache = new mc.Client(@config.memcache.ip, mc.Adapter.json);
		@options.memcache.connect () =>
        console.log "Connected to the " + @config.memcache.ip + " memcache!"

		
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
		
		@registerControllers()
		@deleteMinified(@config.pubDir + '/js/require')
		
		# register JSON-RPC methods must be before the bodyParser
		@jsonRpcServer = new JsonRpcServer()
		@jsonRpcServer.registerMethods()
		
		@app.post('/jsonrpc', (req, res) =>
			@jsonRpcServer.handleRequest(req, res)
		)
		
		@app.configure( =>
			@app.set("view engine", "jade")
			@app.set("views", @config.appDir + "/views/")
			@app.set('view options', { pretty: true })
		)
		
		@app.use(@app.router)
		
		server = @app.listen(@options.port)
		console.log("Server started on port " + @options.port + ".")
		
		# setup socket.io
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
			url = '/index'

		console.log(url)
		return url

	handleJadeRequest: (req, res) ->
		url = 'views' + Bootstrap.realUrl(req.url)

		# fetch the raw jade
		fs.readFile(url, 'utf8', (err, data) ->
			if err
				res.write(err)
			else
				# compile the jade
				jc = jade.compile(data, { client: true, filename: url, debug: false, compileDebug: true }).toString()
				fn = url.replace(/\.jade$/, '').replace(/[\/-]/g, '_')
				res.write('document.' + fn + ' = ' + jc)

			res.end()
		)

	handleRequest: (req, res) =>
		url = Bootstrap.realUrl(req.url)
		console.log(url)

		# setup ready handler
		res.setView = (view) ->
			res.renderView = view

		res.ready = () ->
			if res.renderView
				res.render(res.renderView, res.view)
			else
				res.render(url.substr(1), res.view)

		# run
		controller = new (require(@config.appDir + "/controllers" + url + ".coffee"))
		res.view = {}
		if controller.init == undefined || controller.init(req, res)
			controller.run(req, res)

	registerControllers: (path = 'controllers') ->
		if path == 'controllers'
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
			console.log("Registering controller '" + path.substr(11, path.length - 18) + "'")
			@app.all(path.substr(11, path.length - 18), @handleRequest)
			@app.all(path.substr(11, path.length - 18) + ".jade", @handleJadeRequest)

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