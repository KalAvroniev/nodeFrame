class API_View_Panels_ProtradaVideo extends app.modules.lib.APIController
	module.exports = @

	constructor: () ->
		super
		options =
			"requireUserSession": true

	render: (req, cb) ->
		r = {}
		cb(null, r)