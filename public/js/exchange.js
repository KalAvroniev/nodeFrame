(function() {
	var domLoaded = 0;

	$("#main-container").one({ ajaxUnload: onDomUnload });

	function onDomLoad() {
		domLoaded++;

		/*if (domLoaded > 1) {
			return;
		}*/

		// tabs
		$("#portfolio-data-tabs a").click(function( e ) {
			e.preventDefault();
			$( this ).tab("show");
		})

		// show the two tabs for this page
		$(".sectional-tabs li").addClass("hidden");
		$(".sectional-tabs li#watchlist").removeClass("hidden");

		$(".sectional-tabs").addClass("singular");

		$( window ).on( "resize", windowResize );
		$( window ).on( "scroll", windowScroll );
	}

	function onDomUnload() {
		$(".ajax-spinner").show();

		$( window ).off( "resize", windowResize );
		$( window ).off( "scroll", windowScroll );

		// note that we don't bother deleting the tinyscrollbar, as it will be
		// removed when the DOM elements are.
	}

	function windowResize() {
		// stub
	}

	function windowScroll() {
		// stub
	}
})();

$( document ).ready(function() {
	// update counter
	$("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr( "data-alerts", $(".protrada .alert-count").attr("data-alerts") );
});