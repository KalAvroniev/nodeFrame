fs = require('fs')
util = require('util')

class SessionStore extends require('connect').session.Store
	module.exports = @

	constructor: () ->
		@sessions = {}

	# try and load the previous session
	fs.readFile('session_data', 'utf8', (err, data) =>
		if err
			return console.error(err)
		else
			@sessions = JSON.parse(data)
	)

	defaultCallback: (err) ->
		# nothing

	get: (sid, cb = @defaultCallback) ->
		cb(null, @sessions[sid])

	set: (sid, data, cb = @defaultCallback) ->
		@sessions[sid] = data
		@save(() ->
			cb(null)
		)

	save: (cb) ->
		fs.writeFile("session_data", JSON.stringify(@sessions), (err) ->
			if err
				console.error("Session data could not be saved: " + err)
			else
				console.log("Session data saved.")
				
			cb()
		)

	destroy: (sid, cb = @defaultCallback) ->
		delete @sessions[sid]
		@save(() ->
			cb(null)
		)

	all: (cb = @defaultCallback) ->
		cb(@sessions)

	clear: (cb = @defaultCallback) ->
		@sessions = {}
		cb()

	length: (cb = @defaultCallback) ->
		cb(@sessions.length)