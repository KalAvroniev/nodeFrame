requirejs = require('requirejs')
fs = require('fs')
util = require('util')

class Modules_Admin extends app.modules.lib.Controller
	module.exports = @

	constructor: () ->
		super
		@modMasterParams(
			require_conf: 'admin'
			expires: 10
		)
		@view = 'admin'
		
	run: (req, res, url, cb) ->
		if not res.locals.everyauth.loggedIn
			@releaseResourcesSync()
			return res.redirect('/login') 
		#res.renderView = 'admin'
		
		res.view = 
			id: "spine"
			layout: true

		@minifyJS()
		
		#need to add user id to the url
		#req.url = req.url + ? + user_id
		super

	minifyJS: () ->
		config =
			baseUrl: './public/js'
			mainConfigFile: './public/js/require-config/' + @params.require_conf + '.js'
			skipModuleInsertion: true
			name: './require-config/' + @params.require_conf
			out: './public/js/require/' + @params.require_conf + '.js'
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