// always declare variables first
var verticalScroll = "body";

// derived from http://stackoverflow.com/a/2866613
Number.prototype.toMoney = function( decimals, decimal_sep, thousands_sep ) {
	var n = this,
		c = isNaN( decimals ) ? 2 : Math.abs( decimals ), // if decimal is zero we must take it, it means user does not want to show any decimal
		d = decimal_sep || ".", // if no decimal separator is passed we use the comma as default decimal separator (we MUST use a decimal separator)

		// according to [http://stackoverflow.com/questions/411352/how-best-to-determine-if-an-argument-is-not-sent-to-the-javascript-function]
		// the fastest way to check for not defined parameter is to use typeof value === "undefined"
		// rather than doing value === undefined.
		t = ( typeof thousands_sep === "undefined" ) ? "," : thousands_sep, // if you don't want ot use a thousands separator you can pass empty string as thousands_sep value

		sign = ( n < 0 ) ? "-" : "",

		// extracting the absolute value of the integer part of the number and converting to string
		i = parseInt( n = Math.abs(n).toFixed(c) ) + "",

		j = ( ( j = i.length ) > 3 ) ? j % 3 : 0;

	return sign + ( j ? i.substr( 0, j ) + t : "" ) + i.substr( j ).replace( /(\d{3})(?=\d)/g, "$1" + t ) + ( c ? d + Math.abs( n - i ).toFixed( c ).slice(2) : "" );
};

$( document ).ready(function() {	
	// dropdowns
	$(".dropdown-toggle").dropdown();

	// this must be assigned after the jade template is loaded in, see $.pv3.panel.show()
	/*$("#import-export, .x-panel").click(function() {
		if ( $("#section-panel").hasClass("hidden") ) {
			$("#section-panel").removeClass("hidden");
			$( this ).addClass("active");
		} else {
			$("#section-panel").addClass("hidden")
			$(".sectional-tabs .active").removeClass("active");
		}

		return false;
	});*/

	$( window ).resize(function() {
		// update fake scrollbars
		$("#notifications").not(".native").tinyscrollbar_update("relative");
	});

	$("#system-help, #live-help-status, #live-help-info > a").on( "click", function( e ) {
		e.preventDefault();

		$.pv3.growl.show( "error", "The Live Help system is coming soon." );
	});

	// now setup the socket for push notifications
	document.socketio = io.connect( "http://" + location.host );
	document.socketio.on( "logout", function() {
		// force logout
		document.location = '/login';
	});

	// the first thing we need to do is fetch the recent notifications
	$.jsonrpc(
		"notifications/fetch",
		{},
		function ( data ) {
			var notif = new NotificationsController( data.notifications );

			notif.render();
			
			// now setup the socket for push notifications
			document.socketio.on( "notification", function( msg ) {
				notif.notifications.unshift( msg.data );
				notif.render();
			});
		}
	);

	// this is already called in moo.js!
	/*$.pv3.state.get(function () {
		$.pv3.state.restoreModule();
	});*/

	/*// setup Tiptip "training wheel" tooltips
	$("#tiptip_holder .hide-bubbles").live( "click", function( e ) {
    	$("body").addClass("no-bubbles");
		e.preventDefault();
		return false;
	});

	var lipsum = " This is Photoshop's version of Lorem Ipsum. Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum aucto <a href='#' class='hide-bubbles' title='Permanently hide all help bubbles'>Turn off all bubbles</a>";

	$(".sectional-tabs").tipTip(
		{
			defaultPosition: "bottom",
			maxWidth: "165px",
			keepHover: true,
			edgeOffset: 0,
			content: lipsum,
			delay: 1000
		}
	);
	$("#member-options").tipTip(
		{
			defaultPosition: "left",
			maxWidth: "165px",
			keepHover: true,
			edgeOffset: 15,
			content: lipsum,
			delay: 1000
		}
	);
	$('#sale-type').tipTip(
		{
			defaultPosition: "bottom",
			maxWidth: "165px",
			keepHover: true,
			edgeOffset: 20,
			content: lipsum,
			delay: 1000
		}
	);

	$('#graph-settings').tipTip(
		{
			defaultPosition: "top",
			maxWidth: "165px",
			keepHover: true,
			edgeOffset: 15,
			content: lipsum,
			delay: 1000
		}
	);

	$('#grid-view input#domain-title').tipTip(
		{
			defaultPosition: "top",
			maxWidth: "165px",
			keepHover: true,
			edgeOffset: 15,
			content: lipsum,
			delay: 1000
		}
	);

	$('#thetableclone input#domain-title').tipTip(
		{
			defaultPosition: "bottom",
			maxWidth: "165px",
			keepHover: true,
			edgeOffset: 16,
			content: lipsum,
			delay: 1000
		}
	);*/
});

function togglePanel( selectorName, contentCallback ) {
	var $panel = $("#section-panel");

	// already visible
	if ( $panel.data("tab") == selectorName ) {
		$panel.addClass("hidden").removeData("tab");
	} else {
		if ( $panel.hasClass("hidden") ) {
			$panel.removeClass("hidden");
		} else {
			$( this ).siblings().removeClass("active");
		}

		$panel.html( contentCallback() ).data( "tab", selectorName );
	}

	if ( $panel.hasClass("hidden") ) {
		$( this ).removeClass("active");
	} else {
		$( this ).addClass("active");
	}
}

// ---
// PUSH/FETCH NOTIFICATIONS
// ---

function NotificationsController( notifications ) {
	this.notifications = notifications;
}

NotificationsController.prototype.render = function() {
	var ns = this.notifications;

	// if there is data, fetch the template and render
	$.jade.getTemplate(
		"notifications/generic",
		function( fn ) {
		
			$( "#protrada-msgs.no-alerts" ).removeClass( "no-alerts" )
			$( "#protrada-msgs .alerts-listing" ).html( " " );

			for ( var i = 0; i < ns.length; ++i ) {
				var notif = $.jade.renderSync( fn, ns[i] );
				$("#protrada-msgs").append( notif );
			}

			// update counter
			$(".protrada .alert-count").attr( "data-alerts", ns.length );

			$("aside #notifications:not(.native)").tinyscrollbar_update("relative");
		},
		function( error ) {
			alert( error );
		}
	);
};
