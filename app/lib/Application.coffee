express = require('express')
connect = require('connect')
fs = require('fs')
jade = require('jade')
JsonRpcServer = require('./JsonRpcServer.coffee').JsonRpcServer
SessionStore = require('./SessionStore.coffee').SessionStore
SocketIoServer = require('./SocketIoServer.coffee').SocketIoServer

class exports.Application

	jsonRpcServer = new JsonRpcServer()
	socketIoServer = new SocketIoServer()
	
	start: () ->
		# register JSON-RPC methods
		jsonRpcServer.registerMethods()
	
		# create server
		@app = express.createServer()
		@app.use(express.static(__dirname + '/../../public'))
		
		# sessions
		@app.use(express.cookieParser())
		@app.use(express.session({ 'secret': "protrada", 'store': new SessionStore() }))
		
		@registerControllers()
		@app.post('/jsonrpc', @jsonRpcRequest)
		@app.set('view engine', 'jade')
		
		# default layout
		@app.set('view options', { pretty: true, layout: "../layouts/default.jade" });
		
		# setup socket.io
		socketIoServer.setJsonRpcServer(jsonRpcServer)
		io = require('socket.io').listen(@app)
		io.sockets.on('connection', (socket) ->
			socketIoServer.addClient(socket)
		)
		
		# setup the auto broadcaster
		#setInterval(
		#	() ->
		#		socketIoServer.broadcastToAll()
		#	, 3000
		#)
		
		# listen
		@app.listen(8181)
		console.log("Server started.")
		
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
				fn = url.replace(/\.jade$/, '').replace(/\//g, '_');
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
		jsonRpcServer.call(
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
		controller.run(
			req,
			res
		)
	
	jsonRpcRequest: (req, res) ->
		jsonRpcServer.handleRequest(req, res)
		
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
