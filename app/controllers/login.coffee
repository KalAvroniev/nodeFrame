util = require('util')

class exports.Controller
	
	run: (req, res) ->
		console.log(req.body)
		if req.body.username == 'protrada' and req.body.password == 'test'
			req.session.user = {
				'user_id': 123
			}
			res.redirect('/home')
		else
			res.redirect('/?error=' + escape("Your login isn't correct."))
