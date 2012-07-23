class exports.Controller

	run: (req, res) ->
		sid = req.cookies.SESSIONID
		req.session.destroy(sid)
		res.redirect('/')
