express = require('express')
fs = require('fs')
JsonRpcServer = require('./JsonRpcServer.coffee').JsonRpcServer

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
		@app.use(express.session({ secret: "protrada" }))
		
		@registerControllers()
		@app.post('/jsonrpc', @jsonRpcRequest)
		@app.set('view engine', 'jade');
		
		# default layout
		@app.set("view options", { layout: "../layouts/default.jade" });
		
		# listen
		@app.listen(8181)
		console.log("Server started.")
	
	handleRequest: (req, res) ->
		# clean URL
		url = req.url.replace(/\/+$/, '')
		if url.indexOf('?') >= 0
			url = url.substr(0, url.indexOf('?'))
		if url == ''
			url = '/index'
		
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
			@app.all(path.substr(11, path.length - 18), @handleRequest)
