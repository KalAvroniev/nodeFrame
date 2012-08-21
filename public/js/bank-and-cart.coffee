(->
	onDomLoad = ->
		++domLoaded
		return  if domLoaded > 1


		# update counter
		$("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr "data-alerts", $(".protrada .alert-count").attr("data-alerts")

		# checkout (stripe) panel
		$(".go-checkout").on("click"
			, ( e ) ->
				e.preventDefault()

				Panels.add({
					id: "checkout"
					url: "modules/bank-and-cart/panels/checkout"
					size: "mini"
					temporary: true
					h1: "checkout"
					h2: "items in cart"
					}
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
		
	domLoaded = 0
	$("#main-container").one ajaxUnload: onDomUnload
	onDomLoad()
	$(document).on "click", "#toggle-side-bar, #x-side-bar", (e) ->
		windowResize()
		return
	
	return
)()
