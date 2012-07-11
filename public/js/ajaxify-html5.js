// Derived from https://gist.github.com/854622
(function(window,undefined){
	
	// Prepare our Variables
	var
		History = window.History,
		$ = window.jQuery,
		document = window.document;

	// Check to see if History.js is enabled for our Browser
	if ( !History.enabled ) {
		return false;
	}

	// Wait for Document
	$(function(){
		// Prepare Variables
		var
			/* Application Specific Variables */
			contentSelector = '#main-container',
			scriptClassSelector = 'script[data-dynamic]',
			$content = $(contentSelector).filter(':first'),
			$menu = $('nav:first').filter(':first'),
			activeClass = 'selected',
			activeSelector = '.selected',
			menuChildrenSelector = '> ul > li',
			/* Application Generic Variables */
			$body = $(document.body),
			rootUrl = History.getRootUrl(),
			initialState = History.getState(),
			initialUrl = initialState.url,
			initialRelativeUrl = initialUrl.replace(rootUrl,'');

		selectMenu(initialUrl, initialRelativeUrl);
		
		// Ensure Content
		if ( $content.length === 0 ) {
			$content = $body;
		}

		// Internal Helper
		$.expr[':'].internal = function(obj, index, meta, stack){
			// Prepare
			var
				$this = $(obj),
				url = $this.attr('href')||'',
				isInternalLink;
			
			// Check link
			isInternalLink = url.substring(0,rootUrl.length) === rootUrl || url.indexOf(':') === -1;
			
			// Ignore or Keep
			return isInternalLink;
		};
		
		// HTML Helper
		var documentHtml = function(html){
			// Prepare
			var result = String(html)
				.replace(/<\!DOCTYPE[^>]*>/i, '')
				.replace(/<(html|head|body|title|meta|script)([\s\>])/gi,'<div class="document-$1"$2')
				.replace(/<\/(html|head|body|title|meta|script)\>/gi,'</div>')
			;
			
			// Return
			return result;
		};
		
		// Ajaxify Helper
		$.fn.ajaxify = function(){
			// Prepare
			var $this = $(this);
			
			// Ajaxify
			$this.find('a:internal.ajaxy').click(function(event){
				// Prepare
				var
					$this = $(this),
					url = $this.attr('href'),
					title = $this.attr('title')||null;
				
				// Continue as normal for cmd clicks etc
				if ( event.which == 2 || event.metaKey ) { return true; }
				
				// Ajaxify this link
				History.pushState(null,title,url);
				event.preventDefault();
				return false;
			});
			
			// Chain
			return $this;
		};
		
		// Ajaxify our Internal Links
		$body.ajaxify();
		
		// Hook into State Changes
		$(window).bind('statechange',function(){
			// Prepare Variables
			var
				State = History.getState(),
				url = State.url,
				relativeUrl = url.replace(rootUrl,'');

			// Set Loading
			$body.addClass('loading');

			// Start Fade Out
			// Animating to opacity to 0 still keeps the element's height intact
			// Which prevents that annoying pop bang issue when loading in new content
			$content.animate({opacity:0},800);

			// The event to signal that the DOM data is being unloaded
			$content.triggerHandler('ajaxUnloading');

			$body.find(scriptClassSelector).remove();
			
			// Ajax Request the Traditional Page
			$.ajax({
				url: url,
				success: function(data, textStatus, jqXHR){
					// Prepare
					var
						$data = $(documentHtml(data)),
						$dataContent = $data.find(contentSelector).filter(':first'),
						contentHtml, $scripts;

					if ($dataContent.length == 0) {
						$dataContent = $data;
					}

					// Fetch the scripts
					$scripts = $dataContent.find('.document-script');
					if ( $scripts.length ) {
						$scripts.detach();
					}

					// Fetch the content
					contentHtml = $dataContent.html()||$data.html();
					if ( !contentHtml ) {
						document.location.href = url;
						return false;
					}
					
					selectMenu(url, relativeUrl);

					// Update the content
					$content.stop(true,true);
					$content.html(contentHtml).ajaxify().css('opacity',100).show().attr('class', $dataContent.attr('class'));

					// Update the title
					document.title = $data.find('.document-title:first').text();
					try {
						document.getElementsByTagName('title')[0].innerHTML = document.title.replace('<','&lt;').replace('>','&gt;').replace(' & ',' &amp; ');
					}
					catch ( Exception ) { }

					// Add the scripts
					$scripts.each(function(index){

						var $script = $(this),
							scriptText = $script.text(),
							scriptNode = document.createElement('script'),
							scriptSrc = $script.attr('src');

						scriptNode.appendChild(document.createTextNode(scriptText));

						if (typeof scriptSrc !== 'undefined' && scriptSrc != '') {
							scriptNode.src = scriptSrc;
						}

						scriptNode.setAttribute('data-dynamic', '1');

						scriptNode.onload = function() {

							if (index + 1 >= $scripts.length) {
								// fire the event
								$content.triggerHandler('ajaxLoaded');
							};
						};

						document.body.appendChild(scriptNode);
					});
					
					// trigger the event when we're not waiting for any
					// scripts
					if ($scripts.length == 0) {
						$content.triggerHandler('ajaxLoaded');
					}

					// Complete the change
					$body.removeClass('loading');
	
					// Inform Google Analytics of the change
					if ( typeof window.pageTracker !== 'undefined' ) {
						window.pageTracker._trackPageview(relativeUrl);
					}

					// Inform ReInvigorate of a state change
					if ( typeof window.reinvigorate !== 'undefined' && typeof window.reinvigorate.ajax_track !== 'undefined' ) {
						reinvigorate.ajax_track(url);
						// ^ we use the full url here as that is what reinvigorate supports
					}
				},
				error: function(jqXHR, textStatus, errorThrown){
					document.location.href = url;
					return false;
				}
			}); // end ajax

		}); // end onStateChange

		function selectMenu(url, relativeUrl) {

			if (relativeUrl == '' || relativeUrl == '/') {
				relativeUrl = 'home';
			}

			// Update the menu
			var $menuChildren = $menu.find(menuChildrenSelector);
			$menuChildren.filter(activeSelector).removeClass(activeClass);
			$menuChildren = $menuChildren.has('a[href^="'+relativeUrl+'"],a[href^="/'+relativeUrl+'"],a[href^="'+url+'"]');
			if ( $menuChildren.length === 1 ) { $menuChildren.addClass(activeClass); }

		}

	}); // end onDomLoad

})(window); // end closure
