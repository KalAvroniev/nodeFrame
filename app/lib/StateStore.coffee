fs = require('fs')
UserState = require('./UserState.coffee').UserState

class exports.StateStore
	
	constructor: () ->
		@users = {}
		
		# try and load the previous session
		fs.readFile('state_data', 'utf8', (err, data) ->
			if err
				return console.error(err)
			else
				console.log(data)
				@sessions = JSON.parse(data)
		)
		
	defaultCallback: () ->
		# does nothing
	
	get: (user_id, cb) ->
		# go fetch the state from a database...
		# but for now well just create a default state if it doesnt exist
		if not @users[user_id]
			@users[user_id] = new UserState()
			@save()
		
		cb(@users[user_id])
	
	set: (user_id, data, cb) ->
		@users[user_id] = data
		@save(() ->
			cb(null)
		)
	
	update: (user_id, name, value, cb) ->
		if not @users[user_id]
			@users[user_id] = {}
		console.log("StateStore: " + name + " = " + value)
		@users[user_id][name] = value
		@save(() ->
			cb(null)
		)
	
	save: (cb = @defaultCallback) ->
		fs.writeFile("state_data", JSON.stringify(@users), (err) ->
			if err
				console.error("State data could not be saved: " + err)
			else
				console.log("State data saved.")
			cb()
		)
	
	destroy: (user_id, cb) ->
		delete @users[user_id]
		cb(null)
