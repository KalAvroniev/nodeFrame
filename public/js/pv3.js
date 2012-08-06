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
		Scrollbars.update("notifications");
	});

	$("#system-help, #live-help-status, #live-help-info > a").on( "click", function( e ) {
		e.preventDefault();

		TaskStatus.show( "error", "The Live Help system is coming soon." );
	});

	// now setup the socket for push notifications
	document.socketio = io.connect( "http://" + location.host );
	document.socketio.on( "logout", function() {
		// force logout
		document.location = "/login";
	});

	// the first thing we need to do is fetch the recent notifications
	$.jsonrpc( "notifications/fetch", {}, function ( data ) {
		var notif = new NotificationsController( data.notifications );

		notif.render();
		
		// now setup the socket for push notifications
		document.socketio.on( "notification", function( msg ) {
			notif.notifications.unshift( msg.data );
			notif.render();
		});
	});
});

function togglePanel( selectorName, contentCallback ) {
	var $this = $( this ),
		$panel = $("#section-panel");

	// already visible
	if ( $panel.data("tab") == selectorName ) {
		$panel.addClass("hidden").removeData("tab");
	} else {
		if ( $panel.hasClass("hidden") ) {
			$panel.removeClass("hidden");
		} else {
			$this.siblings().removeClass("active");
		}

		$panel.html( contentCallback() ).data( "tab", selectorName );
	}

	if ( $panel.hasClass("hidden") ) {
		$this.removeClass("active");
	} else {
		$this.addClass("active");
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
	$.jade.getTemplate( "notifications/generic", function( fn ) {
		$("#protrada-msgs.no-alerts").removeClass("no-alerts").find(".alerts-listing").html(" ");

		for ( var i = 0; i < ns.length; ++i ) {
			var notif = $.jade.renderSync( fn, ns[i] );
			$("#protrada-msgs").append( notif );
		}

		// update counter
		$(".protrada .alert-count").attr( "data-alerts", ns.length );

		Scrollbars.update("notifications");
	},
	function( error ) {
		alert( error );
	});
};
