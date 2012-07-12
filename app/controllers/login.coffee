util = require('util')

class exports.Controller

	run: (req, res) ->
		if req.body.username == 'protrada' and req.body.password == 'test'
			req.session.user = {
				'user_id': 123
			}
			res.redirect('/home')
		else
			res.redirect('/?error=' + escape("Your login information is incorrect. Please try again or use the forgot button."))
