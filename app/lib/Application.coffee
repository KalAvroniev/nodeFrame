express = require('express')
fs   = require('fs')
jade = require('jade')
path = require('path')
JsonRpcServer = require('./JsonRpcServer.coffee').JsonRpcServer
SessionStore = require('./SessionStore.coffee').SessionStore
StateStore = require('./StateStore.coffee').StateStore
SocketIoServer = require('./SocketIoServer.coffee').SocketIoServer

class exports.Application

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
		
		options = 
			publicDir: path.join(__dirname, '/../../public'),
			viewsDir: path.join(__dirname, '/../views'),
			domain: 'd2liqzzjm9hyrw.cloudfront.net',
			bucket: 'alpha-protrada-com',
			key: 'AKIAI654DO6KCXT5K54A',
			secret: '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',
			hostname: 'localhost',
			port: 8181,
			ssl: true,
			production: true
					
		
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
		url = 'views' + @Application.realUrl(req.url)
		
		# fetch the raw jade
		fs.readFile(url, 'utf8', (err, data) ->
			if err
				res.write(err)
			else
				# compile the jade
				jc = jade.compile(data, { client: true, filename: url, debug: true, compileDebug: true }).toString()
				fn = url.replace(/\.jade$/, '').replace(/[\/-]/g, '_');
				res.write('document.' + fn + ' = ' + jc);
			res.end()
		)
	
	handleDemoRequest: (req, res) ->
		url = @Application.realUrl(req.url)
		console.log(url)
		
		# setup ready handler
		res.setView = (view) ->
			res.renderView = view
		res.ready = () ->
			if res.renderView
				res.render(res.renderView, res.view)
			else
				res.render(url.substr(1, url.length - 9), res.view)
		
		# run
		controller = new (require("../controllers" + url.substr(0, url.length - 8) + ".coffee").Controller)
		
		# get data for view
		@jsonRpcServer.call(
			url.substr(9, url.length - 17),
			{},
			(result, error) ->
				if error
					console.error(error)
					res.write('Error ' + error.code + ": " + error.message)
					return res.end()
				
				res.view = result
				
				return controller.run(
					req,
					res
				)
		)
	
	handleRequest: (req, res) ->
		url = @Application.realUrl(req.url)
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
		controller = new (require("../controllers" + url + ".coffee").Controller)
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
			@app.all(path.substr(11, path.length - 18) + ".jsonrpc", express.bodyParser(), @handleDemoRequest)
	
	loadConfig: (config) ->
		@config = require('../config/' + config + '.coffee').config
