Controller = require(app.config.appDir + '/lib/Controller.coffee')

class Index extends Controller
	module.exports = @
	
	constructor: () ->
		@params = {require_conf: '/js/require-config/require-conf'}

	run: ( req, res ) ->
		res.setView('index')
		res.view[key] = val for key, val of @params
		
		if not req.session.user
			return res.redirect("/login")
			
		res.ready()
		
	setViewParams: (params) ->
		@params = params
