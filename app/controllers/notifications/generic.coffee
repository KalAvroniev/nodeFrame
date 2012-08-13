util = require('util')

class Notifications_Generic
	module.exports = @

	run: (req, res) ->
		res.view.layout = null
		res.ready()
