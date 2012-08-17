Controller = require(app.config.appDir + '/lib/Controller.coffee')
requirejs = require('requirejs')
fs = require('fs')

class Index extends Controller
	module.exports = @
	
	constructor: () ->
		@params = 
			require_conf: 'index'
			

	run: ( req, res ) ->
		res.setView('index')
		res.view[key] = val for key, val of @params
		
		if not req.session.user
			return res.redirect("/login")
		
		@minifyJS()
		
		res.ready()
		
	setViewParams: (params) ->
		@params = params

	minifyJS: () ->
	  config =
			baseUrl: '../public/js'
			mainConfigFile: '../public/js/require-config/' + @params.require_conf + '.js'
			skipModuleInsertion: true
			name: './require-config/' + @params.require_conf
			out: '../public/js/require/' + @params.require_conf + '.js'
			optimize: 'none'		
			excludeShallow: ["require-config/" + @params.require_conf]
			fs.exists app.config.pubDir + '/js/require/' + @params.require_conf + '.js', (exists) ->
				if not exists
					requirejs.optimize config, () ->
				return
			return