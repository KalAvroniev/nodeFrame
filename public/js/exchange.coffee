(->
	onDomLoad = ->
		domLoaded++
		return	if domLoaded > 1

		# tabs
		$("#portfolio-data-tabs a").click((e) ->
			e.preventDefault()
			$(this).tab("show")
			return			
		)
		
		# TEMPORARY INSERT OF ALL MODULE PANELS
			
		$("#temp-make-offer").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("temp make offer")

				Panels.add(
					id: "moo1"
					url: "/modules/exchange/panels/make-offer"
					temporary: true
					h1: "temp-make-offer"
					h2: "moo in here"
					, true
				)
				return			
		)
			
		$("#temp-place-bid").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("temp place bid")

				Panels.add(
					id: "moo2"
					url: "/modules/exchange/panels/place-bid"
					temporary: true
					h1: "temp-place-bid"
					h2: "moo in here"
					, true
				)
				return			 
		)
			
		$("#temp-backorder").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("temp backorder")

				Panels.add(
					id: "moo3"
					url: "/modules/exchange/panels/backorder"
					temporary: true
					h1: "temp-backorder"
					h2: "moo in here"
					, true
				)
				return				
		)
				
		$("#temp-watchlist").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("temp watchlist")			

				Panels.add(
					id: "moo4"
					url: "/modules/exchange/panels/watchlist"
					temporary: true
					h1: "temp-watchlist"
					h2: "moo in here"
					, true
				)
				return			 
		)
			
		$("#temp-advanced-search").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("advanced search")						

				Panels.add(
					id: "moo5"
					url: "/panels/advanced-search"
					temporary: true
					h1: "advanced-search"
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
					id: "moo6"
					url: "/panels/export-data"
					temporary: true
					h1: "export-data"
					h2: "moo in here"
					, true
				)
				return			
		)
		
		$("#temp-domain-details").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("temp domain details")						

				Panels.add(
					id: "moo7"
					url: "/panels/domain-details"
					temporary: true
					h1: "temp-domain-details"
					h2: "moo in here"
					, true
				)
				return			
		)

		# show the two tabs for this page
		$(".sectional-tabs li").addClass("hidden")
		$(".sectional-tabs li#watchlist").removeClass("hidden")
		$(".sectional-tabs").addClass("singular")
		$(window).on("resize", windowResize)
		$(window).on("scroll", windowScroll)
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
	return
)()
	
$(document).ready ->
	# update counter
	$("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr "data-alerts", $(".protrada .alert-count").attr("data-alerts")
	return
