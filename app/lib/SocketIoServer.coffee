jade = require('jade')
fs = require('fs')

class SocketIoServer
	module.exports = @

	constructor: () ->
		@clients = []

	setJsonRpcServer: (jsonRpcServer) ->
		@jsonRpcServer = jsonRpcServer

	setupListeners: (client) ->
		#client.on('update-state', (data) =>
		#	data.user_id = 123
		#	@jsonRpcServer.call(
		#		'user/update-state',
		#		data,
		#		(result, error) ->
		#			if error
		#				console.error(error)
		#			console.log(result)
		#	)
		#)

	addClient: (client) ->
		app.logger("SocketIOServer: addClient " + client)
		@setupListeners(client)
		@clients.push(client)

	receive: (data) ->
		app.logger(data)

	broadcastToAll: () ->
		app.logger("BROADCASTING TO " + @clients.length + " CLIENTS")
		@clients.forEach((client) =>
			client.emit('notification', {
				'data': {
					'type': 				'preview',
					'title': 				'Preview',
					'time_ago': 			"" + Math.random() + ' hours',
					'h5': 					"1 hour left & you're currently winning!",
					'domain': 				'icanhazauction.com',
					'action_description': 	'do something',
					'description': 			"The auction for this domain will finish on 15th Jan, " +
											"2012 @ 5:40pm, and you are currently winning! Remember though, this " +
											'can change very quickly however. <a title="view preview now" href="">Watch this auction live</a>'
				}
			})
		)
