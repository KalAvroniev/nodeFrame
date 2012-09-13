$.jade = {}
$.jade.getTemplate = (url, success, options) ->
	# is it already loaded?
	fnRaw = url.replace(/[\/-]/g, "_")
	fn = undefined
	fnRaw = fnRaw.substr(1)  if fnRaw.charAt(0) is "_"
	fn = "views_modules_" + fnRaw
	return success(fn)  if document[fn] isnt `undefined`
	
	# we need to load it
	$.ajax({
		url: "/" + url + ".jade"
		dataType: "script"
		success: ->
			fnRaw = url.replace(/[\/-]/g, "_")
			fn = undefined
			fnRaw = fnRaw.substr(1)  if fnRaw.charAt(0) is "_"
			fn = "views_modules_" + fnRaw
			success fn
			return

		failure: (error) ->
			alert error
			return
	})
	return

$.jade.renderSync = (fn, obj, failure) ->
	attrs = (o) ->
		r = " "
		$.each o, (i, n) ->
			r += i + "=\"" + n + "\""
			return
		r

	document[fn] obj, attrs, ((val) ->
			val
		)
		, failure