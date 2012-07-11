util = require('util')

class exports.Controller
	
	run: (req, res) ->
		console.log(req.body)
		if req.body.submit
			# validate login
			if req.body.user == 'protrada' and req.body.pass == 'test'
				req.session.user = {
					'user_id': 123
				}
			else
				res.setView('index')
		res.view.session = util.inspect(req.session, false, 10)
		res.ready()
