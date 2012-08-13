# this class handles all the data required to restore a user to the state
# they were at when they last visited Protrada
class exports.UserState
	
	constructor: () ->
		# setup the default state
		@modules = {}
		@modules.selected = 'home'
