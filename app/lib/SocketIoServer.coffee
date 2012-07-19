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
			client.emit('notification', {
				'data': {
					'type': 'preview',
					'title': 'Preview',
					'time_ago': "" + Math.random() + ' hours',
					'h5': "1 hour left & you're currently winning!",
					'domain': 'icanhazauction.com',
					'action_description': 'do something',
					'description': "The auction for this domain will finish on 15th Jan, " +
						"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
						'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
				}
			})
			
			#receive
			#socket.on('my other event', (data) ->
			#	console.log("SOCKET: " + data);
			#)
		)
