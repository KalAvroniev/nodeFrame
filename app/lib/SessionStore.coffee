util = require('util')

class SessionStore extends require('express').session.Store
	module.exports = @

	constructor: () ->
		@sessions = {}
	
		@Store = new (if app.config.store is 'memcache' then require('./MemcacheStore') else require('./FileStore'))
		@Store.read('session_data', (err, data) =>
			if err
				console.error(err)
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
		@Store.write("session_data", JSON.stringify(@sessions), (err) ->
			if err
				console.log(err)
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
