util = require('util')

class Grid_Row
	module.exports = @

	run: (req, res) ->
		res.view.layout = null
		res.ready()
