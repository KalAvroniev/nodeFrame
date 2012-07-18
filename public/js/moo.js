$(document).ready(function () {
	
	/* this code doesnt work 
	$('#main-container').on('ajaxLoaded', function() {
		$('.ajax-spinner').hide();
	});
	
	$('#main-container').on('ajaxUnloading', function() {
		$('.ajax-spinner').show();
	});
	*/
	
	var module = document.URL.substr(document.URL.lastIndexOf('/') + 1);
	
	navigate(module);
	
	$('#toggle-condensed').click(function() {
		if ($('body').hasClass('condensed')) {
			$('.condensed').removeClass('condensed');
			$(this).removeClass('active');
		} else {
			$('body').addClass('condensed');
			$(this).addClass('active');						
		}
		return false
	});
	
	if ($('body').hasClass('condensed')) {
			$('#toggle-condensed').addClass('active');
	} else {
			$('#toggle-condensed').removeClass('active');						
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

// Setup open/close sidebar element functions	
$(document).on("click","#toggle-side-bar, #x-side-bar",function(e){
	
	console.log('moooooo');
	
	var aside = $('aside');
	
	if (aside.hasClass('active')) {
	
		//hide the sidebar
		
		// work around webkit not redrawing when innerHtml altered
		/*var mainContainer = $('#main-container')[0];
		mainContainer.style.display = 'none';
		mainContainer.offsetHeight;
		mainContainer.style.display = 'block';*/
		
		aside.removeClass('active');
		$('body').addClass('sidebar-hidden');
	
	} else {
	
 		//show the sidebar
 		
 		// work around webkit not redrawing when innerHtml altered
 		/*var mainContainer = $('#main-container')[0];
		mainContainer.style.display = 'none';
		mainContainer.offsetHeight;
		mainContainer.style.display = 'block';*/
	
		aside.addClass('active');
		$('body').removeClass('sidebar-hidden');
    	$('aside #notifications:not(.native)').tinyscrollbar_update('relative');
 	
 	}
	
});	