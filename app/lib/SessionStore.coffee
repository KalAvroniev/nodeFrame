fs = require('fs')

class exports.SessionStore extends require('connect').session.Store
	
	constructor: () ->
		@sessions = {}
		
		# try and load the previous session
		fs.readFile('session_data', 'utf8', (err, data) ->
			if err
				return console.error(err)
			else
				console.log(data)
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
		cb(null)
	
	#all: (cb = @defaultCallback) ->
	
	clear: (cb = @defaultCallback) ->
		console.log("SessionStore: clear()")
		@sessions = {}
		cb()
	
	#length: (cb = @defaultCallback) ->
	#	cb(@sessions.length)
