$( document ).ready(function() {
	var module = document.URL.substr( document.URL.lastIndexOf("/") + 1 );

	if ( module !== "" ) {
		$.pv3.state.update( "modules.selected", module );
		$.pv3.state.get(function() {
			$.pv3.state.restoreModule();
		});
	}

	$("#ui-controls").on( "click", "a", function( e ) {
		var classes = {
			condensed: "condensed",
			downgrade: "mobile",
			helpbubbles: "help"
		};

		e.preventDefault();

		// toggle body class
		$( document.body ).toggleClass( classes[this.id.replace(/toggle|-/g, "")] );

		// toggle active UI state
		$( this ).toggleClass("active");
	});

	// TODO: this should all be replaced with code that relies on the <user/state> JSONRPC call (when it's implemented)
	$("#toggle-condensed").toggleClass( "active", $(document.body).hasClass("condensed") );
	$("#toggle-downgrade").toggleClass( "active", $(document.body).hasClass("mobile") );

	$("#toggle-sys-menu").on( "click", function( e ) {
		e.preventDefault();
		$( this ).add("#sys-menu").toggleClass("active");
    });

	$("#x-sys-menu").on( "click", function( e ) {
		e.preventDefault();
		$("#sys-menu, #toggle-sys-menu").removeClass("active");
	});

	$("#mode-rocker").on( "click", function( e ) {
		e.preventDefault();

		// toggle between Protrada and Devname
		$("#system-rocker").find("h3").toggleClass("hidden");

		// toggle active UI state
		$( this ).toggleClass("active");
	});
});

// setup open/close sidebar element functions
$( document ).on( "click", "#toggle-side-bar, #x-side-bar", function() {
	
	var $aside = $("aside");

	$aside.toggleClass("active");
	$( document.body ).toggleClass("sidebar-hidden").toggleClass("sidebar-open");

	// animate main body (the best way to force webkit to re-render children dom elements)
	$("#main-container, .task-status").animate( { width: ($aside.hasClass("active") ? "99.999" : "100") + "%" }, 200 );

	// update fake scrollbars
	$("#notifications").not(".native").tinyscrollbar_update("relative");
});

// remove alert item from sidebar
$( document ).on( "click", ".x-alert-msg", function() {
	$( this ).parent().slideUp( 450, function() {
		$( this ).remove();

		// update fake scrollbars
		$("#notifications").not(".native").tinyscrollbar_update("relative");
	});
});