Controller = require("../lib/Controller.coffee").Controller

class exports.Controller extends Controller

	run: ( req, res ) ->
		res.view.layout = null
		res.view.moo = "moo goes the cow"

		if not req.session.user
			return res.redirect("/login")

		res.ready()