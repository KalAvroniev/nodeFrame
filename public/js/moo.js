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
			
		 
	
	

						
			
});

// Setup open/close sidebar element functions	
$(document).on("click","#toggle-side-bar, #x-side-bar",function(e){
	
	console.log('moooooo');
	
	var aside = $('aside');
	
	if (aside.hasClass('active')) {
	
		// work around webkit not redrawing when innerHtml altered
		var mainContainer = $('#main-container')[0];
		mainContainer.style.display = 'none';
		mainContainer.offsetHeight;
		mainContainer.style.display = 'block';
		
		aside.removeClass('active');
		$('body').addClass('sidebar-hidden');
	
	} else {
	
 		//show the sidebar
 		// work around webkit not redrawing when innerHtml altered
 		var mainContainer = $('#main-container')[0];
		mainContainer.style.display = 'none';
		mainContainer.offsetHeight;
		mainContainer.style.display = 'block';
	
		aside.addClass('active');
		$('body').removeClass('sidebar-hidden');
    	$('aside #notifications:not(.native)').tinyscrollbar_update('relative');
 	
 	}
	
});	