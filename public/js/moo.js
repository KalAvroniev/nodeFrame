$( document ).ready(function() {
	/* this code doesnt work 
	$('#main-container').on('ajaxLoaded', function() {
		$('.ajax-spinner').hide();
	});

	$('#main-container').on('ajaxUnloading', function() {
		$('.ajax-spinner').show();
	});*/

	var module = document.URL.substr( document.URL.lastIndexOf("/") + 1 );

	navigate( module );

	$("#ui-controls a").on( "click", function() {
		if ( $( this ).hasClass("active") ) {
			$( this ).removeClass("active");
		} else {
			$( this ).addClass("active");
		}

		return false;
	});

	$("#toggle-condensed").click(function() {
		if ( $("body").hasClass('condensed') ) {
			// turn off condensed mode
			console.log("condensed off");
			$("body").removeClass("condensed");
			//$( this ).removeClass("active");
		} else {
			// turn on condensed mode
			console.log("condensed on");
			$("body").addClass("condensed");
			//$( this ).addClass("moo");
		}

		return false
	});

	$("#toggle-downgrade").click(function() {
		if ( $("body").hasClass("mobile") ) {
			// turn off low-fi mode
			console.log("low-fi off");
			$("body").removeClass("mobile");
			//$( this ).removeClass("active");
		} else {
			// turn on low-fi mode
			console.log("low-fi on");
			$("body").addClass("mobile");
			//$( this ).addClass("moo");
		}

		return false
	});	

	if ( $("body").hasClass("condensed") ) {
		console.log("condensed on")
		$("#toggle-condensed").addClass("active");
	} else {
		console.log("condensed off")
		$("#toggle-condensed").removeClass("active");
	}

	if ($('body').hasClass('mobile')) {
		console.log('low-fi on');
		$('#toggle-downgrade').addClass('active');
	} else {
		console.log('low-fi off');
		$('#toggle-downgrade').removeClass('active');
	}	

	$('#toggle-sys-menu').click(function () {

        if ($('#sys-menu').hasClass('active')) {

	        // hide the sys-menu
            $('#sys-menu').removeClass('active');
            $(this).removeClass('active');

        } else {

	        // show the sys menu
            $('#sys-menu').addClass('active')
            $(this).addClass('active');

        }
        return false;
    });	
	

	$('#mode-rocker').on('click', function () {
	
		if ($(this).hasClass('active')) {
			
			// switch to devname mode
			$(this).removeClass('active');
			$('h3.protrada.hidden').removeClass('hidden');
			$('h3.devname').addClass('hidden');
		
		} else {
		
			// switch to protrada mode
			$(this).addClass('active');
			$('h3.protrada').addClass('hidden');
			$('h3.devname.hidden').removeClass('hidden');
	 
		}
		
		return false;
		
	});	
	
	$('#x-sys-menu').on('click', function () {
	
		$('#sys-menu').removeClass('active');
        $('#toggle-sys-menu.active').removeClass('active');
	
		return false;
	
	});

}); // ------------------------------------- Close doc-ready

// setup open/close sidebar element functions	
$( document ).on( "click", "#toggle-side-bar, #x-side-bar", function( e ) {
	var aside = $("aside");

	if ( aside.hasClass("active") ) {
		// hide the sidebar

		// work around webkit not redrawing when innerHtml altered
		//$("#main-container").redraw();		

		/*var mainContainer = $("#main-container")[0];
		mainContainer.style.display = "none";
		mainContainer.offsetHeight;
		mainContainer.style.display = "block";*/

		aside.removeClass("active");
		$("body").addClass("sidebar-hidden");
		$("#main-container").animate( { width: "100%" }, 200 );
		$(".task-status").animate( { width: "100%" }, 200 );
		
	} else {
		// show the sidebar

		// work around webkit not redrawing when innerHtml altered
		//$("#main-container").redraw();

		aside.addClass("active");
		$("body").removeClass("sidebar-hidden");
		$("#main-container").animate( { width: "99.999%" }, 300 );
		$(".task-status").animate( { width: "99.999%" }, 300 );
		$("aside #notifications:not(.native)").tinyscrollbar_update("relative");
	}
});

// onclick Close alert item out of the sidebar
$( document ).on( "click", ".x-alert-msg", function( e ) {
	$( this ).parent().slideUp( 450, function() {
		$( this ).remove();
	   	$("aside #notifications:not(.native)").tinyscrollbar_update("relative");
	});
});