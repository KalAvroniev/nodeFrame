(function() {
	var horizontalScroll = "#grid-view",
		tableHead = "table.floatable",
		innerOuterOffset,
		tableHeaderOffset,
		domLoaded = 0,
		stickyHeaderEnabled = true;

	function onDomLoad() {
		++domLoaded;

		if ( domLoaded > 1 ) {
			return;
		}

		loadDataIntoTable();

		// setup all the events
		$( document.body ).not(".mobile").find(".domain-title").on({
			mouseenter: domainTitleMouseEnter,
			mouseleave: domainTitleMouseLeave
		});

		$("#main-container").on( "click", ".grid-table .sticky", toggleSticky );

		$(".grid-table").children("tbody").on( "click", ".domain-title-cntnr .copy-to-clipboard", preventEvent )
			.on( "click", "td button.favourite", toggleFavourite )
			.on( "click", "td button.select", toggleSelect )
			.on("click", "td:not(#zero-alert)", function() {
				var $this = $( this ),
					$row = $this.closest("tr"),
					parent, rowIsSelected;

				if ( $row.hasClass("child") ) {
					// clicking on the child row
					$row.fadeOut(function() {
						$this.prev().removeClass("row-sel parent-open").remove();
					});
				} else {
					$parent = $row.parent();
					rowIsSelected = $row.hasClass("parent-open");

					// fade out / remove all "open" child rows
					$parent.children("tr.row-sel.child").fadeOut(function() {
						$this.prev().removeClass("row-sel parent-open").remove();
					});

					if ( !rowIsSelected ) {
						$row.addClass("row-sel parent-open");

						$row.after(
							'<tr class="row-sel child" style="display:none;"><td colspan="' + row.find('td').length + '"><div class="child-inner"> <a class="x-row-sel" href="javascript:void(0);">x</a><p><strong>selected domain content</strong> <br>to be placed in here …</p></div></td></tr>'
						);

						$row.next().fadeIn();
					}
				}
			});

		$( window ).on( "resize", windowResize ).on( "scroll", windowScroll );
		$( verticalScroll + ", " + horizontalScroll ).on( "resize", copyHeaderSize );
		$( horizontalScroll ).on( "tsb_scroll", horizontalScroll + " > .scrollbar", UpdateTableHeaders );

		// other... stuff
		$( tableHead ).each(function() {
			var $this = $( this ),
				$parent = $this.parent(),
				originalHeaderRow, cloneTable, clonedHeaderRow;

			if ( $parent.css("position") === "relative" ) {
				$parent.addClass("divTableWithFloatingHeader");
			} else {
				$this.wrap("<div class=\"divTableWithFloatingHeader\" style=\"position: relative;\" />");
			}

			originalHeaderRow = $( "thead:first", this );
			cloneTable = $("#thetableclone").children("table");
			clonedHeaderRow = cloneTable.append( originalHeaderRow.clone() );

			clonedHeaderRow.closest("#thetableclone").css({
				top: $("header#main").height(),
				left: $this.css("margin-left") + $this.offset().left
			});

			clonedHeaderRow.addClass("tableFloatingHeader");
			originalHeaderRow.addClass("tableFloatingHeaderOriginal");

			copyHeaderSize();
		});

		$( horizontalScroll ).tinyscrollbar({
			axis: "x",
			scroll: false
		});

		innerOuterOffset = getInnerOuterOffset();
		tableHeaderOffset = getTableHeaderOffset();

		positionHorizScroll();

		UpdateTableHeaders();
	}

	onDomLoad();

	function onDomUnload() {
		$("div.divTableWithFloatingHeader").remove();

		$( document.body ).not(".mobile").find("td.domain-title").off({
			mouseenter: domainTitleMouseEnter,
			mouseleave: domainTitleMouseLeave
		});

		$("#main-container").off("click", ".grid-table th.sticky", toggleSticky);

		$(".grid-table").children("tbody").off( "click", ".domain-title-cntnr .copy-to-clipboard", preventEvent )
			.off( "click", "td button.favourite", toggleFavourite )
			.off( "click", "td button.select", toggleSelect );

		$( window ).off( "resize", windowResize ).off( "scroll", windowScroll );
		$( verticalScroll + ", " + horizontalScroll ).off( "resize", copyHeaderSize );
		$( horizontalScroll ).off( "tsb_scroll", horizontalScroll + " > .scrollbar", UpdateTableHeaders );

		if ( typeof exchangeDomainResults !== "undefined" ) {
			exchangeDomainResults = null;
		}

		// note that we don't bother deleting the tinyscrollbar, as it will be
		// removed when the DOM elements are.
	}

	function preventEvent( e ) {
		e.preventDefault();
		return false;
	}

	function toggleSticky( e ) {
		var spans = $(".grid-table th.sticky").children("span");

		if ( stickyHeaderEnabled ) {
			stickyHeaderEnabled = false;
			spans.removeClass("on").addClass("off");
			$( document.body ).removeClass("sticky-thead");
		} else {
			stickyHeaderEnabled = true;
			spans.addClass("on").removeClass("off");
		}

		UpdateTableHeaders();

		return preventEvent( e );
	}

	function toggleFavourite( e ) {
		$( this ).button("toggle");
		return preventEvent( e );
	}

	function toggleSelect( e ) {
		$( this ).button("toggle");
		return preventEvent( e );
	}

	function domainTitleMouseEnter() {
		$( this ).find( ".domain-title-cntnr .copy-to-clipboard" ).css( "opacity", 1 );
	}

	function domainTitleMouseLeave() {
		$( this ).find( ".domain-title-cntnr .copy-to-clipboard" ).css( "opacity", 0 );
	}

	function windowResize() {
		$( horizontalScroll ).tinyscrollbar_update("relative");

		innerOuterOffset = getInnerOuterOffset();
		tableHeaderOffset = getTableHeaderOffset();

		positionHorizScroll();
		UpdateTableHeaders();
	}

	function windowScroll() {
		$(".btn-group.open").removeClass("open");

		innerOuterOffset = getInnerOuterOffset();
		tableHeaderOffset = getTableHeaderOffset();

		positionHorizScroll();
		UpdateTableHeaders();
	}

	$( document ).on( "click", "#toggle-side-bar, #x-side-bar", function( e ) {
		windowResize();
		windowScroll();
	});

	function getInnerOuterOffset() {
		var scrollOffset = $( verticalScroll ).scrollTop(),
			vertOffset = $( verticalScroll ).offset().top,
			innerOffset = $( horizontalScroll ).offset().top;

		return (innerOffset - scrollOffset) - vertOffset;
	}

	function getTableHeaderOffset() {
		var scrollOffset = $( verticalScroll ).scrollTop(),
			vertOffset = $( verticalScroll ).offset().top,
			tableOffset = $( horizontalScroll + " table" ).offset().top;

		return $("#grid-view .grid-table").offset().top;
	}

	function isTableOnScreen( offset ) {
		var bottomOfScreen = $( window ).scrollTop() + $( window ).height(),
			tableOffset = $( horizontalScroll + " table" ).offset().top;

		offset = offset || 0;

		return ( bottomOfScreen - (tableOffset + offset) >= 0 );
	}

	function positionHorizScroll() {
		var viewHeight = $( verticalScroll ).height(),
			scrollOffset = $( verticalScroll ).scrollTop(),
			scroll = $( horizontalScroll + " > .scrollbar" );

		scroll.css( "display", isTableOnScreen() ? "block" : "none" );
	}

	// derived from https://bitbucket.org/cmcqueen1975/htmlfloatingtableheader/wiki/Home
	function UpdateTableHeaders() {
		$("div.divTableWithFloatingHeader").each(function() {
			var theClone = $(".tableFloatingHeader"),
				theCloneTable = theClone.closest("table"),
				theCloneContainer = theClone.closest("#thetableclone"),
				body = $( document.body );

			if ( !stickyHeaderEnabled ) {
				theCloneContainer.css( "visibility", "hidden" );

				if ( body.hasClass("sticky-thead") ) {
					body.removeClass("sticky-thead");
				}

				return;
			}

			var offset = tableHeaderOffset,
				scrollTop = $( window ).scrollTop(),
				viewport = $( this ).closest(".viewport");

			if ( ((scrollTop + $("header#main").height()) - offset > 0) ) {// && (scrollTop - offset - $(this).height() < 0)) {
				theCloneContainer.css( "visibility", "visible" );

				if ( !body.hasClass("sticky-thead") ) {
					body.addClass("sticky-thead");
				}
			} else {
				theCloneContainer.css( "visibility", "hidden" );

				if ( body.hasClass("sticky-thead") ) {
					body.removeClass("sticky-thead");
				}
			}

			theCloneTable.css({
				left: -$( horizontalScroll ).tinyscrollbar_offset() + "px"
			});

			theCloneContainer.width( viewport.width() );
		});
	}

	function copyHeaderSize() {
		$("div.divTableWithFloatingHeader").each(function() {
			var originalHeaderRow = $( ".tableFloatingHeaderOriginal", this ),
				clonedHeaderRow = $( ".tableFloatingHeader", this );

			// copy cell widths from original header
			$( "th", clonedHeaderRow ).each(function( i ) {
				$( this ).css( "width", $( "th", originalHeaderRow ).eq( i ).css("width") );
			});
		});
	}

	// this function relies on a variable exchangeDomainResults as defined
	// in the global scope
	function loadDataIntoTable() {
		var tableData, table;

		if ( typeof exchangeDomainResults === "undefined" || exchangeDomainResults === null ) {
			return;
		}

		tableData = $.parseJSON( exchangeDomainResults );
		table = $(".grid-table tbody");

		// clean up the table
		table.find("tr").remove();

		if ( !tableData || tableData.error ) {
			if ( tableData ) {
				console.log( "Error retreiving domain data: " + tableData.error );
			}

			table.append("<tr><td id=\"zero-alert\" colspan=\"17\"><span class=\"ff-icon-before\"><a class=\"ff-icon x-zero-alert\" href=\"javascript:void(0);\"></a><strong>Sorry</strong>, there was an error retreiving domain listings. Please try again.</td></tr>");

			return;
		}

		if ( tableData.length === 0 ) {
			table.append("<tr><td id=\"zero-alert\" colspan=\"17\"><span class=\"ff-icon-before\"><a class=\"ff-icon x-zero-alert\" href=\"javascript:void(0);\"></a><strong>Sorry</strong>, we couldn't find any exact matches for this keyword.</td></tr>");
		} else {
			for ( var i = 0; i < tableData.length; ++i ) {
				var domain = tableData[ i ];

				table.append('<tr> \
					<td><button class="btn select" data-toggle="button"></button></td> \
					<td><button class="btn favourite" data-toggle="button"></button></td> \
					<td class="actions"><span class="action-buttons"><a href="#" title="Build website"></a><a href="#" title="List for sale"></a></span></td> \
					<td class="domain-title"><span class="domain-title-cntnr">' + domain.domain.nameonly + ' <span class="tld">' + domain.domain.tld + '</span></span></td> \
					<td class="date">' + domain.auction_details[0].auction_end_date + '</td> \
					<td class="currency">' + domain.auction_details[0].auction_price + '</td> \
					<td>' + domain.auction_details[0].auction_bidders + '</td> \
					<td>' + domain.domain.chars + '</td> \
					<td>' + (domain.domain.dash ? '?' : '-') + '</td> \
					<td>' + domain.domain.tld + '</td> \
					<td>' + (domain.tld_available.com != '0' ? '?' : '?') + '</td> \
					<td>' + (domain.tld_available.net != '0' ? '?' : '?') + '</td> \
					<td>' + (domain.tld_available.org != '0' ? '?' : '?') + '</td> \
					<td>' + domain.pagerank.pagerank + '</td> \
					<td>' + domain.backlinks.edu + '</td> \
					<td>' + domain.backlinks.gov + '</td> \
					<td>' + domain.backlinks.google + '</td> \
				</tr>');
			}
		}
	}
})();