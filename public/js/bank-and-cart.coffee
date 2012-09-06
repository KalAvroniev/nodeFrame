(->
	onDomLoad = ->
		++domLoaded
		return	if domLoaded > 1


		# update counter
		$("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr "data-alerts", $(".protrada .alert-count").attr("data-alerts")

		# checkout (stripe) panel
		$(".go-checkout").on("click"
			, ( e ) ->
				e.preventDefault()

				Panels.add(
					id: "moo"
					url: "/bank-and-cart/panels/checkout"
					size: "mini"
					temporary: true
					h1: "checkout"
					h2: "items in cart"
					, true
				)
				return
		)		
		
		# TEMPORARY INSERT OF ALL MODULE PANELS
		
		$("#temp-checkout").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("temp checkout")

				Panels.add(
					id: "moo1"
					url: "/bank-and-cart/panels/checkout"
					temporary: true
					h1: "temp-checkout"
					h2: "moo in here"
					, true
				)
				return		
		)
			
		$("#temp-export-data").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("export data")

				Panels.add(
					id: "moo2"
					url: "/panels/export-data"
					temporary: true
					h1: "export-data"
					h2: "moo in here"
					, true
				)
				return						
		)
		return
		
	onDomUnload = ->
		$(".ajax-spinner").show()
		$(window).off("resize", windowResize)
		$(window).off("scroll", windowScroll)
		return
		
	# note that we don't bother deleting the tinyscrollbar, as it will be
	# removed when the DOM elements are.
	windowResize = ->

	# stub
	windowScroll = ->
		
	domLoaded = 0
	$("#main-container").one(ajaxUnload: onDomUnload)
	onDomLoad()
	$(document).on("click"
		, "#toggle-side-bar, #x-side-bar"
		, (e) ->
			windowResize()
			return
	)
	
	return
)()
