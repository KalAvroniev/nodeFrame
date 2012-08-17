util = require('util')
requirejs = require('requirejs')
fs = require('fs')

class Login
	module.exports = @
	
	constructor: () ->
		@params = 
			require_conf: 'login'
	
	run: (req, res) ->
		if req.query.submit
			if req.body.username == 'protrada' and req.body.password == 'test'
				req.session.user = {
					'user_id': 123
				}
				req.session.save()
				res.redirect('/home')
			else
				res.redirect('/login?error=' + escape("Your login information is incorrect. Please try again or use the forgot button."))
		else
			res.view.layout = null
			res.view.error = ''
			if req.query.error
				res.view.error = req.query.error
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

			fs.exists app.config.pubDir + '/js/require/' + @params.require_conf + '.js', (exists) ->
				if not exists
					requirejs.optimize config, () ->
				return
			return