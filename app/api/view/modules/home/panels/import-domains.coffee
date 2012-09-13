class API_View_Modules_Home_Panels_ImportDomains extends app.modules.lib.APIController
	module.exports = @

	constructor: () ->
		super
		options =
			"requireUserSession": true

	render: (req, cb) ->
		r = {}
		cb(null, r)