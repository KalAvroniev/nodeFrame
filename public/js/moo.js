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
		
		// update the state
		$.pv3.state.update('system_options.toggles.' + $(this).attr('id'), $(this).hasClass("active"));
	});

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
		
		// update the state
		var selected = $('#system-rocker').find("h3:not(.hidden)").attr('id');
		$.pv3.state.update('system_options.mode', selected);
	});
});
	
// restore the state for the system options
$(document).on('restore', function () {
	var state = $.pv3.state.current.system_options;
	
	// toggle switches
	$.each(state.toggles, function (k, v) {
		var id = "#ui-controls #" + k;
		if((v && !$(id).hasClass('active')) || (!v && $(id).hasClass('active')))
			$(id).click();
	});
	
	// trading/devname
	$("#system-rocker").find("h3").addClass('hidden');
	$("#system-rocker #" + state.mode).removeClass('hidden');
	
	$("#mode-rocker").removeClass('active');
	if(state.mode == 'devname')
		$("#mode-rocker").addClass('active');
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