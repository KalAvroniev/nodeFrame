class Modules_Test extends app.modules.lib.Controller
	module.exports = @

	run: (req, res, url, cb) ->
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
