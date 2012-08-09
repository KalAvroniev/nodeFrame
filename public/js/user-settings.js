$( document ).ready(function () {
	// --- save state
	$('#user-settings-tabs li a').click(function (e) {
		$.pv3.state.update('modules.user-settings.tabs.selected', e.currentTarget.id);
	});

	// General / user settings
	$('#general-tabs li a').click(function (e) {
		var mainTab = $('#user-settings-tabs li.active a')[0].id;
		$.pv3.state.update('modules.user-settings.tabs.' + mainTab + '.tabs.selected', e.currentTarget.id);
	});

	// update counter
	$("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr( "data-alerts", $(".protrada .alert-count").attr("data-alerts") );
});

// --- restore state
$(document).on('restore', function() {
	// restore tabs
	var state = $.pv3.state.current;
	if(state.modules['user-settings'] == undefined)
		return;

	var tabs = state.modules['user-settings'].tabs;
	if(tabs == undefined)
		return;

	// change selected tab
	if(tabs.selected != undefined) {
		$('#user-settings-tabs li a#' + tabs.selected).click();
	}

	// General / user settings
	if(tabs.selected == 'general-btn') {
		if(tabs['general-btn'] == undefined ||
			tabs['general-btn'].tabs == undefined ||
			tabs['general-btn'].tabs.selected == undefined)
			return;

		$('#general-tabs li a#' + tabs['general-btn'].tabs.selected).click();
		return;
	}

	// External account linkage
	if(tabs.selected == 'external-accounts-btn') {
		return;
	}

	// System notification settings
	if(tabs.selected == 'sys-notifications-btn') {
		return;
	}
});

// external account button UI behaviour
$(".account-selection").on( "click", "li:not(.open-for-edit, .more-coming-soon)", function( e ) {
	e.preventDefault();

	if ( $( this ).hasClass("active") ) {
		$( this ).removeClass("active");
	} else {
		$( this ).siblings().removeClass("active").end().addClass("active");
	}
});

$.pv3.state.get();