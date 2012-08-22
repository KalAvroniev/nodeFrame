class API_User_CheckLogin
	module.exports = @

	validate: {}

	options:
		requireUserSession: false

	run: ( req ) ->
		checked = false
		errorMsg = null

		if req.params.username == "protrada" and req.params.password == "test"
			req.options.req.session.user =
				'user_id': 123
			req.options.req.session.save()

			checked = true
		else
			errorMsg = "Your login information is incorrect. Please try again or use the forgot button."

		req.success(checked: checked, errorMsg: errorMsg)