Controller = require(app.config.appDir + '/lib/Controller.coffee')
requirejs = require('requirejs')
fs = require('fs')

class Index extends Controller
	module.exports = @

	constructor: () ->
		@params = 
			require_conf: 'index'
			id: "spine"
			layout: true

	run: ( req, res ) ->		
		res.redirect('/login') if not res.locals.everyauth.loggedIn
		res.setView('index')
		res.view[key] = val for key, val of @params

		@minifyJS()

		res.ready()

	setViewParams: (params) ->
		@params[key] = val for key, val of params

	minifyJS: () ->
		config =
			baseUrl: '../public/js'
			mainConfigFile: '../public/js/require-config/' + @params.require_conf + '.js'
			skipModuleInsertion: true
			name: './require-config/' + @params.require_conf
			out: '../public/js/require/' + @params.require_conf + '.js'
			optimize: 'none'		
			excludeShallow: ["require-config/" + @params.require_conf]

		fs.readFile app.config.pubDir + '/js/require/' + @params.require_conf + '.js', 'utf8', (err, data) ->
			if err
				requirejs.optimize config, () ->
		###
		fs.exists app.config.pubDir + '/js/require/' + @params.require_conf + '.js', (exists) ->
			if not exists
				requirejs.optimize config, () ->
		###
		return