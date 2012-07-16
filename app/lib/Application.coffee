express = require('express')
fs = require('fs')
JsonRpcServer = require('./JsonRpcServer.coffee').JsonRpcServer
SessionStore = require('./SessionStore.coffee').SessionStore

class exports.Application

	jsonRpcServer = new JsonRpcServer()
	
	start: () ->
		# register JSON-RPC methods
		jsonRpcServer.registerMethods()
	
		# create server
		@app = express.createServer()
		@app.use(express.static(__dirname + '/../../public'))
		
		# sessions
		@app.use(express.bodyParser())
		@app.use(express.cookieParser())
		@app.use(express.session({ 'secret': "protrada", 'store': new SessionStore() }))
		
		@registerControllers()
		@app.post('/jsonrpc', @jsonRpcRequest)
		@app.set('view engine', 'jade')
		
		# default layout
		@app.set('view options', { pretty: true, layout: "../layouts/default.jade" });
		
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
		url = 'views/' + @Application.realUrl(req.url)
		console.log(url)
		
		# fetch the raw jade
		fs.readFile(url, 'utf8', (err, data) ->
			if err
				res.write(err)
				console.error(err)
			else
				res.write(data)
			res.end()
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
