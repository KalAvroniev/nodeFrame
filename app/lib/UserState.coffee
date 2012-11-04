# this class handles all the data required to restore a user to the state
# they were at when they last visited Protrada
class UserState
	module.exports = @

	constructor: () ->
		# setup the default state
		@modules 			= {}
		@modules.selected 	= 'home'
