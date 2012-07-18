Controller = require('../lib/Controller.coffee').Controller

class exports.Controller extends Controller
	
	run: (req, res) ->
		# get data
		req.jsonRpcServer.call(
			req.query.view,
			{},
			(result, error) =>
				if error
					console.error(error)
				console.log(result)
				res.ready()
		)
