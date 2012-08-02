/*
$("#grid-view").grid({
	url: "uri/to/grid/data", // ajax endpoint for grid data
	data: [], // use this array of data for the grid instead of ajaxing it in
	type: "detailed", // is this grid detailed or simple
	stickyHeader: true, // utilise the sticky header
	fakeScrollbars: true // utilise fake scrollbars for table navigation
});
*/

var Grid = function( element, options ) {
	this.grid = $( element );
	this.options = {
		url: null, // ajax endpoint for grid data
		data: null, // use this array of data for the grid instead of ajaxing it in
		type: "detailed", // is this grid detailed or simple
		stickyHeader: false, // utilise the sticky header
		fakeScrollbars: false // utilise fake scrollbars for table navigation
	};

	$.extend( this.options, options );

	this.init();
};

Grid.prototype = {
	constructor: Grid,

	init: function() {
		var that = this,
			$grid = this.grid;

		$.jsonrpc( this.options.url, {}, function( data ) {
			//console.log( data );

			$.jade.getTemplate( "grid/table", function () {
				$grid.html( $.jade.renderSync("views_grid_table", data, that.error) );

				$.jade.getTemplate( "grid/row", function() {
					var records = data.records;

					for ( var i = 0; i < records.length; ++i ) {
						$grid.find("tbody").append( $.jade.renderSync("views_grid_row", records[ i ], that.error) );
					}

					// run setup
					that.setup();
				});
			});
		});
	},

	error: function( error ) {
		alert( error );
	},

	expandRow: function() {
		var $row = $( this );

		// collapse any other open rows
		$row.siblings(".parent-open").trigger("click");

		$row.addClass("row-sel parent-open")
			.after( "<tr class=\"row-sel child\" style=\"display: none;\"><td colspan=\"" + $row.find("td").length + "\"><div class=\"child-inner\"> <a class=\"x-row-sel\" href=\"javascript:void(0);\">x</a><p><strong>selected domain content</strong> <br />to be placed in here &hellip;</p></div></td></tr>")
			.next().fadeIn();
	},

	collapseRow: function() {
		var $row = $( this );

		if ( $row.hasClass("child") ) {
			$row.fadeOut(function() {
				$row.prev().removeClass("row-sel parent-open").end().remove();
			});
		} else {
			$row.next().fadeOut(function() {
				$row.removeClass("row-sel parent-open").next().remove();
			});
		}
	},

	setup: function() {
		var that = this;

		if ( this.options.stickyHeader ) {
			this.grid.addClass("tiny-scrollbar-horiz");
		}

		$( document.body ).not(".mobile").find(".domain-title").on({
			mouseenter: this.domainTitleMouseEnter,
			mouseleave: this.domainTitleMouseLeave
		});

		$("#main-container").on( "click", ".grid-table .sticky", { grid: this }, this.toggleSticky );

		this.grid.find("tbody").on( "click", "tr:not(.parent-open, .child)", this.expandRow );
		this.grid.find("tbody").on( "click", ".parent-open, .child", this.collapseRow );

		$(".grid-table").find("tbody").on( "click", ".domain-title-cntnr .copy-to-clipboard", function( e ) { e.preventDefault(); })
			.on( "click", "td button.favourite", this.toggleFavourite )
			.on( "click", "td button.select", this.toggleSelect );

		$( window ).on( "resize", { grid: this }, this.windowResize ).on( "scroll", { grid: this }, this.windowScroll );
		$( verticalScroll ).add( this.grid ).on( "resize", this.copyHeaderSize );
		this.grid.on( "tsb_scroll", ".scrollbar", this.updateTableHeaders );

		$( "table.floatable", this.grid ).each(function() {
			var $this = $( this ),
				$parent = $this.parent(),
				originalHeaderRow,
				cloneTable,
				clonedHeaderRow;

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

			that.copyHeaderSize();
		});

		this.grid.tinyscrollbar({ axis: "x", scroll: false });

		this.positionHorizScroll();
		this.updateTableHeaders();
	},

	teardown: function() {
		//
	},

	toggleSticky: function( e ) {
		var grid = e.data.grid;

		e.preventDefault();

		grid.options.stickyHeader = !grid.options.stickyHeader;
		grid.grid.find(".sticky").find("span").toggleClass("on off");
		$( document.body ).toggleClass("sticky-thead");

		grid.updateTableHeaders();
	},

	toggleFavourite: function( e ) {
		e.preventDefault();
		$( this ).button("toggle");
	},

	toggleSelect: function( e ) {
		e.preventDefault();
		$( this ).button("toggle");
	},

	domainTitleMouseEnter: function() {
		$( this ).find(".domain-title-cntnr .copy-to-clipboard").css( "opacity", 1 );
	},

	domainTitleMouseLeave: function() {
		$( this ).find(".domain-title-cntnr .copy-to-clipboard").css( "opacity", 0 );
	},

	windowResize: function( e ) {
		var grid = e.data.grid;

		grid.grid.tinyscrollbar_update("relative");

		grid.positionHorizScroll();
		grid.updateTableHeaders();
	},

	windowScroll: function( e ) {
		var grid = e.data.grid;

		$(".btn-group.open").removeClass("open");

		grid.positionHorizScroll();
		grid.updateTableHeaders();
	},

	// not needed?
	/*getInnerOuterOffset: function() {
		var scrollOffset = $( verticalScroll ).scrollTop(),
			vertOffset = $( verticalScroll ).offset().top,
			innerOffset = this.grid.offset().top;

		return ( innerOffset - scrollOffset ) - vertOffset;
	},*/

	getTableHeaderOffset: function() {
		var scrollOffset = $( verticalScroll ).scrollTop(),
			vertOffset = $( verticalScroll ).offset().top,
			tableOffset = $( "table", this.grid ).offset().top;

		return $( ".grid-table", this.grid ).offset().top;
	},

	isTableOnScreen: function( offset ) {
		var bottomOfScreen = $( window ).scrollTop() + $( window ).height(),
			tableOffset = $( "table", this.grid ).offset().top;

		offset = offset || 0;

		return ( bottomOfScreen - (tableOffset + offset) >= 0 );
	},

	positionHorizScroll: function() {
		var viewHeight = $( verticalScroll ).height(),
			scrollOffset = $( verticalScroll ).scrollTop(),
			scroll = $( ".scrollbar", this.grid );

		scroll.css( "display", this.isTableOnScreen() ? "block" : "none" );
	},

	copyHeaderSize: function() {
		$( "div.divTableWithFloatingHeader", this.grid ).each(function() {
			var originalHeaderRow = $( ".tableFloatingHeaderOriginal", this ),
				clonedHeaderRow = $( ".tableFloatingHeader", this );

			// copy cell widths from original header
			$( "th", clonedHeaderRow ).each(function( i ) {
				$( this ).css( "width", $( "th", originalHeaderRow ).eq( i ).css("width") );
			});
		});
	},

	// derived from https://bitbucket.org/cmcqueen1975/htmlfloatingtableheader/wiki/Home
	updateTableHeaders: function() {
		var that = this;

		$("div.divTableWithFloatingHeader").each(function() {
			var theClone = $(".tableFloatingHeader"),
				theCloneTable = theClone.closest("table"),
				theCloneContainer = theClone.closest("#thetableclone"),
				body = $( document.body );

			if ( !that.options.stickyHeader ) {
				theCloneContainer.css( "visibility", "hidden" );

				if ( body.hasClass("sticky-thead") ) {
					body.removeClass("sticky-thead");
				}

				return;
			}

			var offset = that.getTableHeaderOffset(),
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
				left: -that.grid.tinyscrollbar_offset() + "px"
			});

			theCloneContainer.width( viewport.width() );
		});
	}
};

$.fn.grid = function( option ) {
	return this.each(function() {
		var $this = $( this ),
			data = $this.data("grid");

		if ( !data ) {
			$this.data( "grid", (data = new Grid(this, option)) );
		}

		if ( typeof option === "string" ) {
			data[ option ]();
		}
	});
};