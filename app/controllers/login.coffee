util = require('util')
requirejs = require('requirejs')
fs = require('fs')

class Login
	module.exports = @

	constructor: () ->
		@params = 
			require_conf: 'login'

	run: (req, res) ->
			res.view[key] = val for key, val of @params

			@minifyJS()

			res.ready()

	setViewParams: (params) ->
		@params = params			

	minifyJS: () ->
		config =
			baseUrl: '../public/js'
			mainConfigFile: '../public/js/require-config/' + @params.require_conf + '.js'
			skipModuleInsertion: true
			name: 'require-config/' + @params.require_conf
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