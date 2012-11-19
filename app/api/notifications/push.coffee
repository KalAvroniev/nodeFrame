class API_Notifications_Push extends app.modules.lib.APIController
	module.exports = @

	constructor: () ->
		super
		validate =
			"type"				: 
				"description"	: "The type of notification."
				"type"			: "string"
				"required"		: true
				"validator"		: (value) ->
					values = ['dns-change', 'domain-expire', 'domain-won', 'for-sale', 'losing','lost-domain', 'max-bid-lost', 'preview', 'winning']
					return values.indexOf(value) >= 0
			"when"				: 
				"description"	: "The date of the notification."
				"type"			: "timestamp"
				"required"		: false
				"default"		: new Date()

	render: (req, cb) ->
		#return req.error("Some error")
		cb(null, 'cool')
