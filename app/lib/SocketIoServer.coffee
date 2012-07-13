jade = require('jade')
fs = require('fs')

class exports.SocketIoServer

	constructor: () ->
		@clients = []
		
	setJsonRpcServer: (jsonRpcServer) ->
		@jsonRpcServer = jsonRpcServer

	addClient: (client) ->
		console.log("SocketIOServer: addClient " + client)
		@clients.push(client)

	broadcastToAll: () ->
		console.log("BROADCASTING TO " + @clients.length + " CLIENTS")
		@clients.forEach((client) =>
			# render the notification
			fs.readFile('views/notifications/preview.jade', 'utf8', (err,data) ->
				if err
					return console.error(err)
				
				fn = jade.compile(data, {
					#'filename': Used in exceptions, and required when using includes
				})
				html = fn({
					'domain': 'something.com'
				})
				
				client.emit('notification', {
					'html': html
				})
			)
			
			#socket.on('my other event', (data) ->
			#	console.log("SOCKET: " + data);
			#)
		)
