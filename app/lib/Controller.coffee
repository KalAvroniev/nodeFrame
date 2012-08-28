class Controller
	module.exports = @

	init: (req, res) ->
		# check for valid login
		#if !req.session.user
		#	res.redirect('/login')
		#	return false

		# everything is OK
		return true
