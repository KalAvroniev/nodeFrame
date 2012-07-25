fs = require('fs')

class exports.SessionStore extends require('connect').session.Store
	
	constructor: () ->
		console.log('lib/SessionStore.constructor()')
		@sessions = {}
		
		# try and load the previous session
		fs.readFile('session_data', 'utf8', (err, data) ->
			if err
				return console.error(err)
			else
				@sessions = JSON.parse(data)
		)

	defaultCallback: (err) ->
		console.log('lib/SessionStore.defaultCallback()')
		# nothing
	
	get: (sid, cb = @defaultCallback) ->
		console.log('lib/SessionStore.defaultCallback()')
		cb(null, @sessions[sid])
	
	set: (sid, data, cb = @defaultCallback) ->
		console.log('lib/SessionStore.set()')
		@sessions[sid] = data
		@save(() ->
			cb(null)
		)
	
	save: (cb) ->
		console.log('lib/SessionStore.save()')
		fs.writeFile("session_data", JSON.stringify(@sessions), (err) ->
			if err
				console.error("Session data could not be saved: " + err)
			else
				console.log("Session data saved.")
			cb()
		)
	
	destroy: (sid, cb = @defaultCallback) ->
		console.log('lib/SessionStore.destroy()')
		delete @sessions[sid]
		cb(null)
	
	all: (cb = @defaultCallback) ->
		console.log('lib/SessionStore.all()')
		cb(@sessions)
	
	clear: (cb = @defaultCallback) ->
		console.log('lib/SessionStore.clear()')
		@sessions = {}
		cb()
	
	length: (cb = @defaultCallback) ->
		console.log('lib/SessionStore.length()')
		cb(@sessions.length)
