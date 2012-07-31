/*
$("#grid-view").grid({
	url: "uri/to/grid/data", // ajax endpoint for grid data
	data: [], // use this array of data for the grid instead of ajaxing it in
	type: "detailed", // is this grid detailed or simple
	stickyHeader: true, // utilise the sticky header
	fakeScrollbars: true // utilise fake scrollbars for table navigation
});
*/

var Grid = function( grid, options ) {
	this.grid = $( grid );
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
		$.jsonrpc( this.options.url, {}, function( data ) {
			console.log( data );

			$.jade.getTemplate( "grid/row", $.noop );

			$.jade.getTemplate( "grid/table", function( fn ) {
				var records = data.records;

				$("#grid-view").html( $.jade.renderSync(fn, data, function(err){alert(err)}) );

				for ( var i = 0; i < records.length; ++i ) {
					$("#grid-view").find("tbody").append( $.jade.renderSync("views_grid_row", records[ i ], function(err){alert(err)}) );
				}

				// do scrollbar/stick-header/etc setup here?
				$("#grid-view").tinyscrollbar({ axis: "x", scroll: false });
			});
		});

		/*$( document ).on( "click", "#toggle-side-bar, #x-side-bar", function() {
			this.windowResize();
			this.windowScroll();
		});*/
	},

	toggleSticky: function( e ) {
		e.preventDefault();

		this.stickyHeaderEnabled = !this.stickyHeaderEnabled;
		this.grid.find(".sticky").find("span").toggleClass("on off");
		$( document.body ).toggleClass("sticky-thead");

		this.updateTableHeaders();
	},

	toggleFavourite: function( e ) {
		e.preventDefault();
		$( this ).button("toggle");
	},

	toggleSelect: function( e ) {
		e.preventDefault();
		$( this ).button("toggle");
	},

	windowResize: function() {
		this.grid.tinyscrollbar_update("relative");

		innerOuterOffset = this.getInnerOuterOffset();
		tableHeaderOffset = this.getTableHeaderOffset();

		this.positionHorizScroll();
		this.updateTableHeaders();
	},

	windowScroll: function() {
		$(".btn-group.open").removeClass("open");

		innerOuterOffset = this.getInnerOuterOffset();
		tableHeaderOffset = this.getTableHeaderOffset();

		this.positionHorizScroll();
		this.updateTableHeaders();
	},

	getInnerOuterOffset: function() {
		var scrollOffset = $( verticalScroll ).scrollTop(),
			vertOffset = $( verticalScroll ).offset().top,
			innerOffset = this.grid.offset().top;

		return ( innerOffset - scrollOffset ) - vertOffset;
	},

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
		$("div.divTableWithFloatingHeader").each(function() {
			var theClone = $(".tableFloatingHeader"),
				theCloneTable = theClone.closest("table"),
				theCloneContainer = theClone.closest("#thetableclone"),
				body = $( document.body );

			if ( !this.stickyHeaderEnabled ) {
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
				left: -this.grid.tinyscrollbar_offset() + "px"
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