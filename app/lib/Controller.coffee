class exports.Controller
	
	init: (req, res) ->
		# check for valid login
		if !req.session.user
			res.redirect('/')
