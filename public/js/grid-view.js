(function(){

	var horizontalScroll = '#grid-view',
		tableHead = 'table.floatable',
		innerOuterOffset,
		tableHeaderOffset,
		domLoaded = 0,
		stickyHeaderEnabled = true;

	$(document).one({
		ready: onDomLoad
	});

	$('#main-container').one({
		ajaxLoaded: onDomLoad
	});

	$('#main-container').one({
		ajaxUnloading: onDomUnload
	});

	function onDomLoad() {

		domLoaded++;

		if (domLoaded > 1) {
			return;
		}

		loadDataIntoTable();

		// setup all the events
		$('body:not(.mobile) td.domain-title').on({
			mouseenter: domainTitleMouseEnter,
			mouseleave: domainTitleMouseLeave
		});

		$('.grid-table tbody').on('click', '.domain-title-cntnr .copy-to-clipboard', preventEvent);

		$('.grid-table tbody').on('click', 'td button.favourite', toggleFavourite);
		$('.grid-table tbody').on('click', 'td button.select', toggleSelect);

		$('#main-container').on('click', '.grid-table th.sticky', toggleSticky);

		$('.grid-table tbody').on('click', 'td:not(#zero-alert)', function() {

			var row = $(this).closest('tr');

			if (row.hasClass('child')) {
				// clicking on the child row

				row.fadeOut(function() {
					$(this).prev().removeClass('row-sel').removeClass('parent-open');
					$(this).remove();
				});

			} else {

				var parent = row.parent(),
					rowIsSelected = row.hasClass('parent-open');

				// fade out / remove all 'open' child rows
				parent.children('tr.row-sel.child').fadeOut(function() {
					$(this).prev().removeClass('row-sel').removeClass('parent-open');
					$(this).remove();
				});

				if (!rowIsSelected) {

					row.addClass('row-sel').addClass('parent-open');

					row.after(
						'<tr class="row-sel child" style="display:none;"><td colspan="' + row.find('td').length + '"><div class="child-inner"> <a class="x-row-sel" href="javascript:void(0);">x</a><p><strong>selected domain content</strong> <br>to be placed in here …</p></div></td></tr>'
					);

					row.next().fadeIn();
				}

			}

		});

		$(window).on('resize', windowResize);

		$(verticalScroll + ', ' + horizontalScroll).on('resize', copyHeaderSize);

		$(window).on('scroll', windowScroll);

		$(horizontalScroll).on('tsb_scroll', horizontalScroll + ' > .scrollbar', UpdateTableHeaders);

		// other... stuff
		$(tableHead).each(function () {

			var parent = $(this).parent();

			if (parent.css('position') == 'relative') {
				parent.addClass('divTableWithFloatingHeader');
			} else {
				$(this).wrap("<div class='divTableWithFloatingHeader' style='position:relative' />");
			}

			var originalHeaderRow = $("thead:first", this),
				cloneTable = $("#thetableclone table"),
				clonedHeaderRow = cloneTable.append(originalHeaderRow.clone());

			clonedHeaderRow.closest("#thetableclone").css({
				top: $('header#main').height(),
				left: $(this).css("margin-left") + $(this).offset().left
			});

			clonedHeaderRow.addClass("tableFloatingHeader");

			originalHeaderRow.addClass("tableFloatingHeaderOriginal");

			copyHeaderSize();

		});

		$(horizontalScroll).tinyscrollbar({
			axis: 'x',
			scroll: false
		});
		
		innerOuterOffset = getInnerOuterOffset();
		tableHeaderOffset = getTableHeaderOffset(); 

		positionHorizScroll();

		UpdateTableHeaders();

	}

	function onDomUnload() {

		$("div.divTableWithFloatingHeader").remove();

		$('body:not(.mobile) td.domain-title').off({
			mouseenter: domainTitleMouseEnter,
			mouseleave: domainTitleMouseLeave
		});

		$('.grid-table tbody').off('click', '.domain-title-cntnr .copy-to-clipboard', preventEvent);

		$('.grid-table tbody').off('click', 'td button.favourite', toggleFavourite);
		$('.grid-table tbody').off('click', 'td button.select', toggleSelect);
		$('#main-container').off('click', '.grid-table th.sticky', toggleSticky);

		$(window).off('resize', windowResize);
		$(verticalScroll + ', ' + horizontalScroll).off('resize', copyHeaderSize);
		$(window).off('scroll', windowScroll);
		$(horizontalScroll).off('tsb_scroll', horizontalScroll + ' > .scrollbar', UpdateTableHeaders);


		if (typeof exchangeDomainResults !== "undefined") {
			exchangeDomainResults = null;
		}
		// Note that we don't bother deleting the tinyscrollbar, as it will be
		// removed when the DOM elements are.

	}

	function preventEvent(e) {
		e.preventDefault();
		return false;
	}

	function toggleSticky(e) {

		var spans = $('.grid-table th.sticky').children('span');

		if (stickyHeaderEnabled) {
			stickyHeaderEnabled = false;
			spans.removeClass('on');
			spans.addClass('off');
			$('body').removeClass('sticky-thead');
		} else {
			stickyHeaderEnabled = true;
			spans.addClass('on');
			spans.removeClass('off');
		}
		UpdateTableHeaders();
		return preventEvent(e);
	}

	function toggleFavourite(e) {
		$(this).button('toggle');
		return preventEvent(e);
	}

	function toggleSelect(e) {
		$(this).button('toggle');
		return preventEvent(e);
	}

	function domainTitleMouseEnter() {
		$(this).find('.domain-title-cntnr .copy-to-clipboard').css('opacity', '1');
	}

	function domainTitleMouseLeave() {
		$(this).find('.domain-title-cntnr .copy-to-clipboard').css('opacity', '0');
	}

	function windowResize() {

		$(horizontalScroll).tinyscrollbar_update('relative');
		
		innerOuterOffset = getInnerOuterOffset();
		tableHeaderOffset = getTableHeaderOffset();
		positionHorizScroll();
		UpdateTableHeaders();

	}

	function windowScroll() {
		$('.btn-group.open').removeClass('open');

		innerOuterOffset = getInnerOuterOffset();
		tableHeaderOffset = getTableHeaderOffset();
		positionHorizScroll();
		UpdateTableHeaders();
	}

	function getInnerOuterOffset() {
		var scrollOffset = $(verticalScroll).scrollTop(),
			vertOffset = $(verticalScroll).offset().top,
			innerOffset = $(horizontalScroll).offset().top;
		return (innerOffset - scrollOffset) - vertOffset;
	}

	function getTableHeaderOffset() {
		var scrollOffset = $(verticalScroll).scrollTop(),
			vertOffset = $(verticalScroll).offset().top,
			tableOffset = $(horizontalScroll + ' table').offset().top;
		return $('#grid-view .grid-table').offset().top;
	}

	function isTableOnScreen(offset) {
		offset = (typeof offset === "undefined") ? 0 : offset;
		var bottomOfScreen = $(window).scrollTop() + $(window).height(),
			tableOffset = $(horizontalScroll + ' table').offset().top;
		return (bottomOfScreen - (tableOffset + offset) >= 0);
	}

	function positionHorizScroll() {
		var viewHeight = $(verticalScroll).height(),
			scrollOffset = $(verticalScroll).scrollTop(),
			scroll = $(horizontalScroll + ' > .scrollbar');
		if (isTableOnScreen()) {
			// on-screen
			scroll.css('display', 'block');
		} else {
			// position it off screen
			scroll.css('display', 'none');
		}
	}

	// derived from https://bitbucket.org/cmcqueen1975/htmlfloatingtableheader/wiki/Home
	function UpdateTableHeaders() {

		$("div.divTableWithFloatingHeader").each(function () {

			var theClone = $(".tableFloatingHeader"),
				theCloneTable = theClone.closest('table'),
				theCloneContainer = theClone.closest("#thetableclone"),
				body = $('body');

			if (!stickyHeaderEnabled) {
				theCloneContainer.css("visibility", "hidden");
				if (body.hasClass('sticky-thead')) {
					body.removeClass('sticky-thead');
				}
				return;
			}

			var offset = tableHeaderOffset,
				scrollTop = $(window).scrollTop(),
				viewport = $(this).closest('.viewport');

			if (((scrollTop + $("header#main").height()) - offset > 0)) {// && (scrollTop - offset - $(this).height() < 0)) {
				theCloneContainer.css("visibility", "visible");
				if (!body.hasClass('sticky-thead')) {
					body.addClass('sticky-thead');
				}
			} else {
				theCloneContainer.css("visibility", "hidden");
				if (body.hasClass('sticky-thead')) {
					body.removeClass('sticky-thead');
				}
			}

			theCloneTable.css({
				left: -$(horizontalScroll).tinyscrollbar_offset() + 'px'
			});

			theCloneContainer.width(viewport.width());

		});
	}

	function copyHeaderSize() {

		$("div.divTableWithFloatingHeader").each(function () {

			var originalHeaderRow = $(".tableFloatingHeaderOriginal", this);
			var clonedHeaderRow = $(".tableFloatingHeader", this);
			// Copy cell widths from original header
			$("th", clonedHeaderRow).each(function (index) {
				var cellWidth = $("th", originalHeaderRow).eq(index).css('width');
				$(this).css('width', cellWidth);
			});
		});

	}

	// This function relies on a variable exchangeDomainResults defined in the
	// global scope
	function loadDataIntoTable() {

		if (typeof exchangeDomainResults === "undefined" || exchangeDomainResults == null) {
			return;
		}

		var tableData = $.parseJSON(exchangeDomainResults);

		var table = $('.grid-table tbody');

		// clean up the table
		table.find('tr').remove();

		if (!tableData || tableData.error) {

			if (tableData) {
				console.log("Error retreiving domain data: " + tableData.error);
			}

			table.append('<tr> \
				<td id="zero-alert" colspan="17"><span class="ff-icon-before"><a class="ff-icon x-zero-alert" href="javascript:void(0);"></a><strong>Sorry</strong>, there was an error retreiving domain listings. Please try again.</td> \
			</tr>')

			return;
		}

		if (tableData.length == 0) {

			table.append('<tr> \
				<td id="zero-alert" colspan="17"><span class="ff-icon-before"><a class="ff-icon x-zero-alert" href="javascript:void(0);"></a><strong>Sorry</strong>, we couldn\'t find any exact matches for this keyword.</td> \
			</tr>')

		} else {

			for (var i = 0; i < tableData.length; i++) {
				var domain = tableData[i];
				table.append('<tr> \
					<td><button class="btn select" data-toggle="button"></button></td> \
					<td><button class="btn favourite" data-toggle="button"></button></td> \
					<td class="actions"><span class="action-buttons"><a href="#" title="Build website"></a><a href="#" title="List for sale"></a></span></td> \
					<td class="domain-title"><span class="domain-title-cntnr">' + domain.domain.nameonly + ' <span class="tld">' + domain.domain.tld + '</span></span></td> \
					<td class="date">' + domain.auction_details[0].auction_end_date + '</td> \
					<td class="currency">' + domain.auction_details[0].auction_price + '</td> \
					<td>' + domain.auction_details[0].auction_bidders + '</td> \
					<td>' + domain.domain.chars + '</td> \
					<td>' + (domain.domain.dash ? '✔' : '-') + '</td> \
					<td>' + domain.domain.tld + '</td> \
					<td>' + (domain.tld_available.com != '0' ? '✔' : '✘') + '</td> \
					<td>' + (domain.tld_available.net != '0' ? '✔' : '✘') + '</td> \
					<td>' + (domain.tld_available.org != '0' ? '✔' : '✘') + '</td> \
					<td>' + domain.pagerank.pagerank + '</td> \
					<td>' + domain.backlinks.edu + '</td> \
					<td>' + domain.backlinks.gov + '</td> \
					<td>' + domain.backlinks.google + '</td> \
				</tr>');
			}

		}
	}

})();
