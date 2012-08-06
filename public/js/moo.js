// crude method of keeping track of fake scrollbars
// will redo much better at some point when other "state machines" are worked out
var protrada = {
	version: "3a2",

	cachedAt: 1343982244107,

	scrollbars: {
		elements: {},

		add: function( identifier, $element, options ) {
			this.elements[ identifier ] = $element.tinyscrollbar( options || {} );
		},

		update: function( identifier, type ) {
			this.elements[ identifier ].tinyscrollbar_update( type || "relative" );
		},

		updateAll: function( type ) {
			var that = this;

			$.each( this.elements, function( i, v ) {
				that.update( i, type );
			});
		},

		offset: function( identifier ) {
			return this.elements[ identifier ].tinyscrollbar_offset();
		},

		remove: function( identifier ) {
			this.elements[ identifier ].children(".scrollbar").remove();
		}
	}
};

var Scrollbars = protrada.scrollbars;

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

	// special class for the side-bar on mobile devices
	// we've already checked for mobile by this stage (index.jade), so rely on class present on body
	if ( $( document.body ).hasClass("mobile") ) {
		$("#notifications").addClass("native");
	}

	// init fake scrollbars on sidebar
	Scrollbars.add( "notifications", $("#notifications").not(".native"), { lockscroll: false } );

	// PETE: Please don't delete this script:
	// UX improvement on the spine nav buttons
	$("#spine-inner").find("nav").find("a").mouseup(function() {
		$( this ).removeClass("active");
	}).mousedown(function() {
		$( this ).addClass("active");
	}).mouseout(function() {
		$( this ).removeClass("active");
	});
});

// setup open/close sidebar element functions
function toggleSidebar( e ) {
	var $aside = $("aside");

	$aside.toggleClass("active");
	$( document.body ).toggleClass("sidebar-hidden").toggleClass("sidebar-open");

	// animate main body (the best way to force webkit to re-render children dom elements)
	$("#main-container, .task-status")
		.delay( $( document.body ).hasClass("sidebar-hidden") ? 200 : 0 )
		.animate( { width: ($aside.hasClass("active") ? "99.999" : "100") + "%" }, 200, function() {
			// update fake scrollbars
			Scrollbars.updateAll();

			// update sticky headers
			$("#grid-view").grid("windowResize");
		});
}

$( document ).on( "click", "#toggle-side-bar, #x-side-bar", function() {
	toggleSidebar();

	// update the state
	$.pv3.state.update( "sidebar.visible", !$( document.body ).hasClass("sidebar-hidden") );
});

// remove alert item from sidebar
$( document ).on( "click", ".x-alert-msg", function() {
	$( this ).parent().slideUp( 450, function() {
		$( this ).remove();

		// update fake scrollbars
		Scrollbars.update("notifications");
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
	Scrollbars.update("notifications");
});

// restore the state for the system options
$( document ).on( "restore", function() {
	var state = $.pv3.state.current.system_options,
		sidebar = $.pv3.state.current.sidebar;

	if ( state !== undefined ) {
		// toggle switches
		$.each( state.toggles, function( k, v ) {
			var id = "#ui-controls #" + k;

			if ( (v && !$( id ).hasClass("active")) || (!v && $( id ).hasClass("active")) ) {
				$( id ).click();
			}
		});

		// trading/devname
		$("#system-rocker").find("h3").addClass("hidden").filter( "#" + state.mode ).removeClass("hidden");
		$("#mode-rocker").removeClass("active").addClass(function() {
			return state.mode === "devname" ? "active" : "";
		});
	}

	// sidebar
	if ( sidebar !== undefined ) {
		// show/hide
		if ( sidebar.visible !== undefined ) {
			if ( (sidebar.visible && $( document.body ).hasClass("sidebar-hidden")) || (!sidebar.visible && !$( document.body ).hasClass("sidebar-hidden")) ) {
				toggleSidebar();
			}
		}
	}
});