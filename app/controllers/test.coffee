Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Test extends Controller
	module.exports = @
	
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
