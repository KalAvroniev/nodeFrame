express = require('express')
fs   = require('fs')
jade = require('jade')
path = require('path')
JsonRpcServer = require('./lib/JsonRpcServer.coffee').JsonRpcServer
SessionStore = require('./lib/SessionStore.coffee').SessionStore
StateStore = require('./lib/StateStore.coffee').StateStore
SocketIoServer = require('./lib/SocketIoServer.coffee').SocketIoServer

class Bootstrap
	module.exports = @

	socketIoServer = new SocketIoServer()
	
	constructor: (@options = {}) ->
		# do nothing
	
	start: () ->
		# register JSON-RPC methods
		@jsonRpcServer = new JsonRpcServer(this)
		@jsonRpcServer.registerMethods()
		
		# load config
		@loadConfig(@options.config)
	
		# create server
		@app = express.createServer()
		@app.use(express.static(__dirname + '/../public'))
		
		options = 
			publicDir: path.join(__dirname, '/../public'),
			viewsDir: path.join(__dirname, '/views'),
			domain: 'd2liqzzjm9hyrw.cloudfront.net',
			bucket: 'alpha-protrada-com',
			key: 'AKIAI654DO6KCXT5K54A',
			secret: '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',
			hostname: 'localhost',
			port: 8181,
			ssl: true,
			production: false
					
		
		# initialize the CDN magic
		CDN = require('express-cdn')(@app, options)
        
        # sessions
		@app.use(express.cookieParser())
		@app.use(express.session({
			'secret': "protrada",
			'store': new SessionStore(),
			'maxAge': 1209600000
		}))
		
		# prepare user states
		@states = new StateStore()
		
		@registerControllers()
		@app.post(
			'/jsonrpc',
			(req, res) =>
				@jsonRpcRequest(req, res)
		)
		@app.set('view engine', 'jade')
		@app.use(express.static(path.join(__dirname, '/../../public')));
		
		# default layout
		@app.set('view options', { pretty: true, layout: "../views/layouts/default.jade" });
		
		# add the dynamic view helper
		@app.dynamicHelpers(CDN: CDN)
		
		# setup socket.io
		socketIoServer.setJsonRpcServer(@jsonRpcServer)
		io = require('socket.io').listen(@app)
		io.sockets.on('connection', (socket) ->
			socketIoServer.addClient(socket)
		)
		
		# listen
		@app.listen(@options.port)
		console.log("Server started on port " + @options.port + ".")
		
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
				fn = url.replace(/\.jade$/, '').replace(/[\/-]/g, '_');
				res.write('document.' + fn + ' = ' + jc);
			res.end()
		)
	
	handleRequest: (req, res) ->
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
		controller = new (require("./controllers" + url + ".coffee"))
		res.view = {}
		if controller.init == undefined || controller.init(req, res)
			controller.run(req, res)
	
	jsonRpcRequest: (req, res) ->
		@jsonRpcServer.handleRequest(req, res)
		
	registerControllers: (path = 'controllers') ->
		if path == 'controllers'
			console.log("Registering Controllers...")
			@app.all('/', express.bodyParser(), @handleRequest)
		
		# read the directory
		try
			files = fs.readdirSync(path)
			files.forEach((file) =>
				if file.substr(0, 1) != '.'
					@registerControllers(path + '/' + file)
			)
		catch e
			console.log("Registering controller '" + path.substr(11, path.length - 18) + "'")
			@app.all(path.substr(11, path.length - 18), express.bodyParser(), @handleRequest)
			@app.all(path.substr(11, path.length - 18) + ".jade", express.bodyParser(), @handleJadeRequest)
	
	loadConfig: (config) ->
		@config = require('./config/' + config + '.coffee').config
