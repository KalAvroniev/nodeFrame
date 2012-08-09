// install JSON-RPC client
$.jsonrpc = function( method, params, success, failure, options ) {
	options = options || {};
	success = success || $.noop;
	failure = failure || function( errMsg, errCode ) {
		console.error( "Error " + errCode + ": " + errMsg );
	};

	var ajax = {
		type: "POST",
		url: "/jsonrpc",
		processData: false,
		dataType: "json",
		data: JSON.stringify({
			jsonrpc: "2.0",
			method: method,
			params: params,
			id: 1
		}),
		success: function( result ) {
			if ( result.error !== undefined && result.error.message ) {
				if ( result.error.message.substr( 0, 8 ) === "!logout:" ) {
					document.location = "/login";
				}

				return failure( result.error.message, result.error.code );
			}

			return success( result.result );
		},
		error: function( jqXHR, textStatus, errorThrown ) {
			return failure( textStatus, 0 );
		}
	};

	if ( options.async !== undefined ) {
		ajax.async = options.async;
	}

	return $.ajax( ajax );
};
$.jsonrpcSync = function( method, params, success, failure, options ) {
	options = options || {};
	options.async = false;

	return $.jsonrpc( method, params, success, failure, options );
};

$.ajaxPanel = function( url, success, failure ) {
	failure = failure || function( errMsg, errCode ) {
		console.error( "Error " + errCode + ": " + errMsg );
	};

	$.ajax({
		type: "GET",
		url: url,
		processData: false,
		success: success
	});
};

$.jade = {};
$.jade.getTemplate = function( url, success, options ) {
	// is it already loaded?
	var fnRaw = url.replace( /[\/-]/g, "_" ),
		fn;

	if ( fnRaw.charAt(0) === "_" ) {
		fnRaw = fnRaw.substr(1);
	}

	fn = "views_" + fnRaw;

	if ( document[ fn ] !== undefined ) {
		return success( fn );
	}

	// we need to load it
	$.ajax({
		url: url + ".jade",
		dataType: "script",
		success: function() {
			var fnRaw = url.replace( /[\/-]/g, "_" ),
				fn;

			if ( fnRaw.charAt(0) === "_" ) {
				fnRaw = fnRaw.substr(1);
			}

			fn = "views_" + fnRaw;

			success( fn );
		},
		failure: function ( error ) {
			alert( error );
		}
	});
};
$.jade.renderSync = function( fn, obj, failure ) {
	var attrs = function( o ) {
		var r = " ";

		$.each( o, function( i, n ) {
			r += i + "=\"" + n + "\"";
		});

		return r;
	}

	return document[ fn ]( obj, attrs, function( val ) {
		return val;
	}, failure );
};

$.pv3 = {};

$.pv3.growl = {};

$.pv3.growl.hide = function() {
	$(".task-status").removeClass("active").css( "display", "none" );
};

/**
 * @param type "success" or "error"
 * @param message HTML message (can be raw text)
 */
$.pv3.growl.show = function( type, message ) {
	$.pv3.growl.hide();

	$( ".task-status." + type ).css( "display", "block" ).addClass("active");

	$(".status-content h2").html( type ).next().html( message );
};

$.pv3.state = {};
$.pv3.state.get = function( success, options ) {
	$.jsonrpc( "user/get-state", {}, function( data ) {
		if ( data !== undefined ) {
			$.pv3.state.current = data;

			if ( success ) {
				success();
			}

			$( document ).ready(function() {
				$( this ).trigger("restore");
			});
		}
	}, function ( error ) {
		console.error( error );
	}, options );
};
$.pv3.state.restoreModule = function () {
	var module = ( !$.pv3.state.current.modules.selected || $.pv3.state.current.modules.selected === "" ) ? "home" : $.pv3.state.current.modules.selected;

	// TODO: fix!
	// for some reason module has an # appended?
	module = module.replace( "#", "" );

	window.history.pushState( "", module, "/" + module );

	$("#main-container").trigger("ajaxUnload");
	$.pv3.state.update( "modules.selected", module );

	$.ajax( "/modules/" + module + "?ajax=1", {
		success: function( data ) {
			$("#ajax-container").html( data );
			$(".selected").removeClass("selected");
			$( "#spine-inner nav li a#nav-" + module ).parent().addClass("selected");
			$(".ajax-spinner").hide();

			// restore panels
			var modules = $.pv3.state.current.modules;

			if ( modules[ modules.selected ] != undefined && modules[ modules.selected ].panel != undefined && modules[ modules.selected ].panel.active != null ) {
				$.pv3.panel.show( modules[ modules.selected ].panel.active.url, modules[ modules.selected ].panel.active.options );
			}
		}
	});
};
$.pv3.state.restore = function() {
	$( document ).ready(function() {
		if ( $.pv3.state.current === undefined ) {
			$.pv3.state.get(function() {
				if ( $.pv3.state.current.modules !== undefined && $.pv3.state.current.modules.selected !== undefined ) {
					$.pv3.state.restoreModule( $.pv3.state.current.modules );
				}
			});
		}
	});
};
$.pv3.state.update = function( stateName, stateValue ) {
	$.jsonrpc( "user/update-state", {
			name: stateName,
			value: stateValue
		}, function ( result ) {
			$.pv3.state.current = result;
		}, function ( error ) {
			console.error( error );
		}
	);
};

$.pv3.panel = {};
$.pv3.panel.show = function ( url, options ) {
	var active = false;

	options = options || {};

	// temporary work-around for absence of panel data
	try {
		active = $.pv3.state.current.modules[ $.pv3.state.current.modules.selected ].panel.active;
	} catch ( _ ) {
		console.warn("$.pv3.state.current.modules.panel is still not being returned!");
	}

	if ( options.jsonrpcMethod == undefined ) {
		options.jsonrpcMethod = "view" + url;
	}

	// TODO: refactor this at some point, as it's duplicated below
	// is this panel already open? then close it
	if ( active && active.options.tabid === options.tabid ) {
		$(".standout-disabled").removeClass("standout-disabled").addClass("standout-tab");

		// restore the standout tab to be the first child of the <ul>
		$(".sectional-tabs").restoreStandoutElement();

		$.pv3.panel.hide();

		return;
	}

	// make the JSON-RPC call
	$.jsonrpc( options.jsonrpcMethod, {}, function( obj ) {
		$.jade.getTemplate( url, function ( fn ) {
			var $sectionalTabs = $(".sectional-tabs"),
				$sectionPanel = $("#section-panel");

			// notify the server that the active tab has changed
			$.pv3.state.update( "modules." + $.pv3.state.current.modules.selected + ".panel.active", { url: url, options: options } );

			// set active tab
			$sectionalTabs.find("li").removeClass("active").filter(".standout-tab").removeClass("standout-tab").addClass("standout-disabled");
			$sectionalTabs.find( "#" + options.tabid ).addClass("active");

			// set the active tab to be the first child of the UL
			$sectionalTabs.reorderActiveElement();

			$sectionPanel.removeClass("hidden panel mini-panel").addClass( options.panel_size );

			$(".ajax-panel-content").html( $.jade.renderSync( fn, obj, function( err, file, line ) {
				$(".ajax-panel-content").html( "Error in " + file + " at line " + line + ": " + err );
			}));

			// fix close handler
			$(".x-panel").unbind("click").click(function() {
				$(".standout-disabled").removeClass("standout-disabled").addClass("standout-tab");

				// restore the standout tab to be the first child of the UL
				$sectionalTabs.restoreStandoutElement();

				// find
				$(".sectional-tabs").find(".temporary-panel-tab").remove();

				return $.pv3.panel.hide();				
				
			});
		});
	});
};

$.pv3.panel.hide = function () {
	var $sectionPanel = $("#section-panel");

	if ( $sectionPanel.hasClass("hidden") ) {
		$sectionPanel.removeClass("hidden");
		$( this ).addClass("active");
	} else {
		$sectionPanel.addClass("hidden")
		$(".sectional-tabs .active").removeClass("active");
	}

	// notify the server that the active tab has changed
	$.pv3.state.update( "modules." + $.pv3.state.current.modules.selected + ".panel.active", null );
};

$.fn.reorderActiveElement = function() {
	return this.children(".active").detach().prependTo( this );
};

$.fn.restoreStandoutElement = function() {
	return this.children(".standout-tab").detach().prependTo( this );
};