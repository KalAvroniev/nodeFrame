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
		$.pv3.state.update( "system_options.toggles." + this.id, $( this ).hasClass("active") );
	});

	$("#toggle-condensed").toggleClass( "active", $( document.body ).hasClass("condensed") );
	$("#toggle-downgrade").toggleClass( "active", $( document.body ).hasClass("mobile") );

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
		$.pv3.state.update( "system_options.mode", $("#system-rocker").find("h3").not(".hidden").attr("id") );
	});
});

// setup open/close sidebar element functions
function toggleSidebar(e) {
	var $aside = $("aside");

	$aside.toggleClass("active");
	$( document.body ).toggleClass("sidebar-hidden").toggleClass("sidebar-open");

	// animate main body (the best way to force webkit to re-render children dom elements)
	$("#main-container, .task-status").animate( { width: ($aside.hasClass("active") ? "99.999" : "100") + "%" }, 200 );

	// update fake scrollbars
	$("#notifications").not(".native").tinyscrollbar_update("relative");
};
$( document ).on( "click", "#toggle-side-bar, #x-side-bar", function (e) {
	toggleSidebar();

	// update the state
	$.pv3.state.update( "sidebar.visible", !$( document.body ).hasClass("sidebar-hidden") );
});

// remove alert item from sidebar
$( document ).on( "click", ".x-alert-msg", function() {
	$( this ).parent().slideUp( 450, function() {
		$( this ).remove();

		// update fake scrollbars
		$("#notifications").not(".native").tinyscrollbar_update("relative");
	});
});



// tabs
$( document ).on( "click", ".nav-tabs li a", function( e ) {
	e.preventDefault();
	$( this ).tab("show");
});
 
 
$( document ).on( "click", "#alert-msgs a", function( e ) {
	e.preventDefault();
 
	$( this ).tab("show");
 
	// update fake scrollbars
	$("#notifications").not(".native").tinyscrollbar_update("relative");
	
});



// restore the state for the system options
$( document ).on( "restore", function() {
	var state = $.pv3.state.current.system_options;
	if(state != undefined) {
		// toggle switches
		$.each( state.toggles, function( k, v ) {
			var id = "#ui-controls #" + k;
	
			if ( (v && !$( id ).hasClass("active")) || (!v && $( id ).hasClass("active")) ) {
				$( id ).click();
			}
		});
	
		// trading/devname
		$("#system-rocker").find("h3").addClass("hidden").find( "#" + state.mode ).removeClass("hidden");
		$("#mode-rocker").removeClass("active");
	
		if ( state.mode === "devname" ) {
			$("#mode-rocker").addClass("active");
		}
	}
	
	// sidebar
	var sidebar = $.pv3.state.current.sidebar;
	if(sidebar != undefined) {
		// show/hide
		if(sidebar.visible != undefined) {
			console.log(sidebar.visible);
			console.log($( document.body ).hasClass("sidebar-hidden"));
			if((sidebar.visible && $( document.body ).hasClass("sidebar-hidden")) ||
				(!sidebar.visible && !$( document.body ).hasClass("sidebar-hidden"))) {
					(function () { toggleSidebar(); })();
			}
		}
	}
});


