Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Test extends Controller
	module.exports = @

	run: (req, res, url) ->
		# get data
		req.jsonRpcServer.call(
			req.query.view
			, {}
			, (result, error) =>
				if error
					console.error(error)
					
				console.log(result)
				super
		)
