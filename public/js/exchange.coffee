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
					id: "temp-make-offer"
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
					id: "temp-place-bid"
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
					id: "temp-backorder"
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
					id: "temp-watchlist"
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
					id: "advanced-search"
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
					id: "export-data"
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
					id: "temp-domain-details"
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
