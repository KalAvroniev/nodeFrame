fs = require('fs')
UserState = require('./UserState.coffee')

class StateStore
	module.exports = @
	
	constructor: () ->
		@users = {}
		
		# try and load the previous session
		fs.readFile('state_data', 'utf8', (err, data) =>
			if err
				return console.error(err)
			else
				@users = JSON.parse(data)
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
	
	reset: (user_id, cb) ->
		@users[user_id] = new UserState()
		@save(() =>
			cb(@users[user_id])
		)
	
	update: (user_id, name, value, cb) ->
		if not @users[user_id]
			@users[user_id] = new UserState()
		
		parts = name.split(/\./)
		for part, i in parts
			if i == 0
				continue;
			path = parts.slice(0, i).join("']['");
			eval("if(this.users[user_id]['" + path + "'] == undefined) this.users[user_id]['" + path + "'] = {};")
		eval("this.users[user_id]['" + parts.join("']['") + "'] = value;")
		
		@save(() =>
			cb(@users[user_id])
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
