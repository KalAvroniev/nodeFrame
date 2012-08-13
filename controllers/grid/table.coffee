util = require('util')

class Grid_Table
	module.exports = @

	run: (req, res) ->
		res.view.layout = null
		res.ready()
