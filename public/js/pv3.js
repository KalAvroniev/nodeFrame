// Derived from http://stackoverflow.com/a/2866613
Number.prototype.toMoney = function(decimals, decimal_sep, thousands_sep)
{
	var n = this,
		c = isNaN(decimals) ? 2 : Math.abs(decimals), //if decimal is zero we must take it, it means user does not want to show any decimal
		d = decimal_sep || '.', //if no decimal separetor is passed we use the comma as default decimal separator (we MUST use a decimal separator)

		/*
			according to [http://stackoverflow.com/questions/411352/how-best-to-determine-if-an-argument-is-not-sent-to-the-javascript-function]
		   the fastest way to check for not defined parameter is to use typeof value === 'undefined'
		   rather than doing value === undefined.
		   */   
		t = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep, //if you don't want ot use a thousands separator you can pass empty string as thousands_sep value

		sign = (n < 0) ? '-' : '',

		//extracting the absolute value of the integer part of the number and converting to string
		i = parseInt(n = Math.abs(n).toFixed(c)) + '',

		j = ((j = i.length) > 3) ? j % 3 : 0;
	return sign + (j ? i.substr(0, j) + t : '') + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : '');
}

var verticalScroll = 'body';

// --------------------------- OPEN READY CALL

$(document).ready(function () {

	// special class for the side-bar on mobile devices
	if( navigator.userAgent.match(/Android/i)
		|| navigator.userAgent.match(/webOS/i)
		|| navigator.userAgent.match(/iPhone/i)
		|| navigator.userAgent.match(/iPad/i)
		|| navigator.userAgent.match(/iPod/i)
		|| navigator.userAgent.match(/BlackBerry/i)
	){
		$('aside #notifications' ).addClass('native');;
	}	

	// Innit bootstrap components below
	
	// tabs
	$('#watchlist-tabs a, #portfolio-data-tabs a').click(function (e) {
		e.preventDefault();
		$(this).tab('show');
	});	
	$('#alert-msgs a').click(function (e) {
		e.preventDefault();
		$(this).tab('show');
		$('aside #notifications:not(.native)').tinyscrollbar_update('relative');
	});	
	
    // dropdowns
    $('.dropdown-toggle').dropdown();

	$('aside #notifications:not(.native)' ).tinyscrollbar();

    // UX improvement on the spine nav buttons
    $('#spine-inner nav a').mouseup(function () {
        $(this).removeClass('active');
    }).mousedown(function () {
        $(this).addClass('active');
    }).mouseout(function () {
        $(this).removeClass('active');
    });

    $('#import-export, .x-panel').click(function () {
                
        if ($('#section-panel').hasClass('hidden')) {

            $('#section-panel').removeClass('hidden');
            $(this).addClass('active');

        } else {

            $('#section-panel').addClass('hidden')
            $('.sectional-tabs .active').removeClass('active');

        }
        return false;
    });


    $('#spine-inner nav a').mouseup(function () {
        $(this).removeClass('active');
    }).mousedown(function () {
        $(this).addClass('active');
    });


    $(window).resize(function () {
        $('aside #notifications:not(.native)').tinyscrollbar_update('relative');
    });


	// SETUP Tiptip "training wheel" tooltips
	var lipsum = " This is Photoshop's version  of Lorem Ipsum. Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum aucto <a href='#' class='hide-bubbles' title='Permanently hide all help bubbles'>Turn off all bubbles</a>"

	$('#tiptip_holder .hide-bubbles').live('click', function(e) {
    	$('body').addClass('no-bubbles');
		e.preventDefault();
		return false;
	});
	
/*
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
	);	
*/


	// onclick Close alert item out of the sidebar

	$('.x-alert-msg').on('click', function () {
	
		$(this).parent().slideUp(450, function() {
    		
    		$(this).remove();
	    	$('aside #notifications:not(.native)').tinyscrollbar_update('relative');
    		
   		});
		
	});
	
	$('#main-container').on('ajaxLoaded', function() {
		$('.ajax-spinner').hide();
	});

	$('#main-container').on('ajaxUnloading', function() {
		$('.ajax-spinner').show();
	});
	
	$('#ui-controls a').on('click', function () {
	
		if ($(this).hasClass('active')) {
			
			$(this).removeClass('active');
		
		} else {
		
			$(this).addClass('active');
	 
		}
		
		return false;
		
	});
	
	

	
	
	

}); // END READY CALL

function togglePanel(selectorName, contentCallback) {

	var panel = $('#section-panel');

	// already visible
	if (panel.attr('data-tab') == selectorName) {

		panel.addClass('hidden');
		panel.attr('data-tab', '');

	} else {

		if (panel.hasClass('hidden')) {
			panel.removeClass('hidden');
		} else {
			$(this).parent().find('.active').removeClass('active');
		}

		panel.html(contentCallback());
		panel.attr('data-tab', selectorName);
	}

	if (panel.hasClass('hidden')) {
		$(this).removeClass('active');
	} else {
		$(this).addClass('active');
	}
	
	

}


// ---
// PUSH NOTIFICATIONS
// ---

$(document).ready(function () {
	document.socketio = io.connect('http://' + location.host);
	document.socketio.on('notification', function (data) {
		console.log(data);
		//$('#protrada-msgs').append(data.html);
		//socket.emit('my other event', { my: 'data' });
	});
});
