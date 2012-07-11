express = require('express')
JsonRpcServer = require('./JsonRpcServer.coffee').JsonRpcServer
fs = require('fs')

class exports.Application

	jsonRpcServer = new JsonRpcServer()
	
	start: () ->
		# register JSON-RPC methods
		jsonRpcServer.registerMethods()
	
		# create server
		@app = express.createServer()
		@app.use(express.static(__dirname + '/../../public'));
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
		if url == ''
			url = '/index'
		
		# setup ready handler
		res.setView = (view) ->
			res.view = view
		res.ready = () ->
			if res.view
				res.render(res.view)
			else
				res.render(url.substr(1))
		
		# run
		controller = new (require("../controllers" + url + ".coffee").Controller)
		controller.run(
			req,
			res
		)
	
	jsonRpcRequest: (req, res) ->
		jsonRpcServer.handleRequest(req, res)
		
	registerControllers: (path = 'controllers') ->
		if path == 'controllers'
			console.log("Registering Controllers...")
			@app.get('/', @handleRequest)
		
		# read the directory
		try
			files = fs.readdirSync(path)
			files.forEach((file) =>
				if file.substr(0, 1) != '.'
					@registerControllers(path + '/' + file)
			)
		catch e
			@app.get(path.substr(11, path.length - 18), @handleRequest)
