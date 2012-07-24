$( document ).ready(function() {
	var domLoaded = 0,
		tradingGraph = null,
		scrollContainer;

	/*$(document).one({
		ready: onDomLoad
	});

	$('#main-container').one({
		ajaxLoaded: onDomLoad
	});*/

	$("#main-container").one( "ajaxLoad", function() {
		$(".ajax-spinner").show();
	});
	$("#main-container").one({ ajaxUnload: onDomUnload });

	function onDomLoad() {
		domLoaded++;

		/*if (domLoaded > 1) {
			return;
		}*/

		$("#status-summary").tinyscrollbar({
			axis: "x",
			scroll: false
		});

		$("#trading-and-trending .graph-options").on( "click", toggleGraphVisible );

		// show the two tabs for this page
		$(".sectional-tabs").removeClass("singular");
		$(".sectional-tabs li").addClass("hidden");
		$(".sectional-tabs li#watchlist").removeClass("hidden");

		$(".sectional-tabs").on( "click", "li#watchlist", showWatchlist );

		// update the scrollable area on window resize
		$( window ).on( "resize", windowResize );
		$( window ).on( "scroll", windowScroll );

		setupTradingGraph();
	}

	function setupTradingGraph() {
		if ( tradingGraph != null || !$("#trading-and-trending .graph-container").is(":visible") ) {
			return;
		}

		createDateGraph(
			"trading-graph",
			[
				{
					label: "Profit",
					lineColor: "#c4c4c4",
					fillColor: "#fff",
					markerColor: "#161413",
					data: [
						[new Date(2012,  0, 12), 9],
						[new Date(2012,  1, 12), 20],
						[new Date(2012,  2, 12), 10],
						[new Date(2012,  3, 12), 15],
					]
				},
				{
					label: "Sales",
					lineColor: "#5d8b10",
					fillColor: "#7fb91c",
					markerColor: "#3b6303",
					data: [
						[new Date(2012,  0, 12), 7],
						[new Date(2012,  1, 12), 17],
						[new Date(2012,  2, 12), 7],
						[new Date(2012,  3, 12), 12],
					]
				},
				{
					label: "Cost Price",
					lineColor: "#b2540c",
					fillColor: "#d66108",
					markerColor: "#753504",
					data: [
						[new Date(2012,  0, 12), 5],
						[new Date(2012,  1, 12), 7],
						[new Date(2012,  2, 12), 15],
						[new Date(2012,  3, 12), 7],
					]
				}
			],
			"%s: <strong>$%s</strong>",
			"1 month",
			300
		);
	}

	onDomLoad();

	function onDomUnload() {
		$(".ajax-spinner").show();

		$( window ).off( "resize", windowResize );
		$( window ).off( "scroll", windowScroll );
		$(".sectional-tabs").off( "click", "li#watchlist", showWatchlist );

		$("#trading-and-trending .graph-options").off( "click", toggleGraphVisible );

		if ( tradingGraph != null ) {
			tradingGraph.destroy();
			tradingGraph = null;
		}

		// note that we don't bother deleting the tinyscrollbar, as it will be
		// removed when the DOM elements are.
	}

	function showWatchlist() {
		togglePanel.call( this, this.id, getWatchlistContent );
	}

	function getWatchlistContent() {
		return "Watchlist content here";
	}

	function toggleGraphVisible() {
		var container = $( this ).closest("#trading-and-trending");

		if ( container.hasClass("graph-hidden") ) {
			// show graph
			container.removeClass("graph-hidden");
			// initialize the graph if necessary
			setupTradingGraph();
		} else {
			container.addClass("graph-hidden");
		}
	}

	function windowResize() {
		var width = $("#main-container").width();

		resizeScrollToWidth( "#status-summary", width );
		resizeScrollToWidth( scrollContainer, width );
	}

	function resizeScrollToWidth( scrollSelector, containerWidth ) {
		var scrollContainer = $( scrollSelector ),
			scrollWidth = scrollContainer.width();

		if ( containerWidth != scrollWidth ) {
			scrollContainer.css({ width: containerWidth + "px" });
		}

		scrollContainer.tinyscrollbar_update("relative");
	}

	function windowScroll() {
		// thank heavens! nothing!
	}

	$( document ).on( "click", "#toggle-side-bar, #x-side-bar", function( e ) {
		windowResize();
	});

	function createDateGraph(elementId, settings, tooltipFormat, tickInterval, minWidthBetweenMarks) {

		var tooltipFormat = (typeof tooltipFormat === "undefined") ? '%s: <strong>$%s</strong>' : tooltipFormat,
			tickInterval = (typeof tickInterval === "undefined") ? '1 month' : tickInterval,
			minWidthBetweenMarks = (typeof minWidthBetweenMarks === "undefined") ? 70 : minWidthBetweenMarks,

			parts = tickInterval.split(' '),
			tickIntervalParts = [parts[0], parts[1]],

			dataArray = [],
			series = [],

			dataMarks = settings[0].data.length,

			graph = $('#' + elementId),
			containerWidth = graph.width(),
			containerHeight = graph.height(),

			// container for the graph so we can resize within the applicable
			// area as specified by the user
			graphContainer = $(document.createElement('div')).css({
				height: containerHeight,
				overflow: 'hidden'
			});

		graph.wrap(graphContainer);

		graphContainer = graph.parent();
			
		// Scrolling area
		if (minWidthBetweenMarks * dataMarks < containerWidth) {
			// recalculate the difference between the graph marks
			minWidthBetweenMarks = containerWidth / dataMarks;
		}

		scrollContainer = $('<div class="tiny-scrollbar-horiz" style="position: relative; width: ' + containerWidth + 'px; height: ' + containerHeight + 'px"><div class="viewport"><div class="overview"></div></div></div>');

		graphContainer.wrap(scrollContainer);

		scrollContainer = graphContainer.closest('.tiny-scrollbar-horiz');

		$('<div class="scrollbar"><div class="track"><div class="thumb"><div class="end"></div></div></div></div>')
			.prependTo(scrollContainer);

		// widen the graph area to be able to fit the whole graph
		containerWidth = minWidthBetweenMarks * dataMarks;
		graph.css('width', containerWidth);
		graphContainer.closest('.overview').css('width', containerWidth);

		$(scrollContainer).tinyscrollbar({
			axis: 'x',
			scroll: false
		});

		// resize the graph and shift it so that the first and last marks are
		// hidden
		graphContainer.css('width', containerWidth);
		graph.css({
			width: containerWidth + minWidthBetweenMarks,
			marginLeft: -(minWidthBetweenMarks / 2)
		});

		for (var set = 0; set < settings.length; set++) {

			var dataSet = [],

				// calculations for going back / forward in a time interval
				first = settings[set].data[0],
				last = settings[set].data[settings[set].data.length -1],
				newFirstDate = new $.jsDate(first[0].getTime()).add(-tickIntervalParts[0], tickIntervalParts[1]),
				newLastDate = new $.jsDate(last[0].getTime()).add(tickIntervalParts[0], tickIntervalParts[1]);

			// 'back' 1 time interval
			dataSet.push([newFirstDate, first[1]]);

			// all the intervals between
			for (var valueIndex = 0; valueIndex < settings[set].data.length; valueIndex++) {
				dataSet.push(settings[set].data[valueIndex]);
			}

			// 'forward' 1 time interval
			dataSet.push([newLastDate, last[1]]);

			dataArray.push(dataSet);

			// setup the series info to pass to jqplot
			series.push({
				label: settings[set].label,
				color: settings[set].lineColor,
				fillColor: settings[set].fillColor || settings[set].lineColor,
				markerOptions: {
					color: settings[set].markerColor || settings[set].lineColor
				}
			});
		}

		// minimum and maxium marks on the graph
		var min = new Date(dataArray[0][0][0].getTime()),
			max = new Date(dataArray[0][dataArray[0].length - 1][0].getTime());

		tradingGraph = $.jqplot(
			elementId,
			dataArray,
			{
				stackSeries: false,

				seriesDefaults: {
					lineWidth: 5, // Width of the line in pixels.
					shadow: false,   // show shadow or not.
					fill: true,        // fill under the line,
					fillAndStroke: true,       // *stroke a line at top of fill area.
					fillAlpha: 0.85,       // *custom alpha to apply to fillColor.
					xaxis: 'x2axis',
					markerOptions: {
						lineWidth: 2,       // width of the stroke drawing the marker.
						size: 20,            // size (diameter, edge length, etc.) of the marker.
						shadow: false       // wether to draw shadow on marker or not.
					},
				},

				axesDefaults: {
					tickOptions: {
						showMark: false,
						showGridline: false, // wether to draw a gridline (across the whole grid) at this tick,
						showLabel: true,    // wether to show the text label at the tick,
						formatString: '',   // format string to use with the axis tick formatter
					},
				},

				series: series,

				axes: {
					yaxis: {
						// same options as axesDefaults
						show: false,
						tickOptions: {
							show: false,
							showLabel: false    // wether to show the text label at the tick,
						},
						showTicks: false,        // wether or not to show the tick labels,
						showTickMarks: false    // wether or not to show the tick marks
					},
					xaxis: {
						// same options as axesDefaults
						show: false,
						tickOptions: {
							show: false,
							showLabel: false    // wether to show the text label at the tick,
						},
						showTicks: false,        // wether or not to show the tick labels,
						showTickMarks: false    // wether or not to show the tick marks
					},
					x2axis: {
						renderer:$.jqplot.DateAxisRenderer,
						tickOptions: {
							formatString:'%b, %e'
						},
						min: min,
						max: max,
						tickInterval: tickInterval,
					}
				},

				gridPadding: {
					left: 0,
					right: 0,
					bottom: 0,
				},

				grid: {
					drawGridLines: false,        // wether to draw lines across the grid or not.
					borderWidth: 0,           // pixel width of border around grid.
					shadow: false,               // draw a shadow for grid.
				},

				highlighter: {
					show: true,
					sizeAdjust: 2,          // pixels to add to the size of filled markers when drawing highlight.
					showTooltip: true,      // show a tooltip with data point values.
					tooltipLocation: 's',   // location of tooltip: n, ne, e, se, s, sw, w, nw.
					fadeTooltip: true,      // use fade effect to show/hide tooltip.
					tooltipFadeSpeed: "100",// slow, def, fast, or a number of milliseconds.
					tooltipOffset: 8,       // pixel offset of tooltip from the highlight.
					useAxesFormatters: true,// use the same format string and formatters as used in the axes to
					tooltipAxes: 'y',    // which axis values to display in the tooltip, x, y or both.
					tooltipContentEditor: function(str, seriesIndex, pointIndex) {
						return $.jqplot.sprintf(
							tooltipFormat,
							tradingGraph.series[seriesIndex].label,
							tradingGraph.data[seriesIndex][pointIndex][1].toMoney()
						);
					}
				}
			}

		);

		// shift the graph so the dots aren't visible on the left hand side
		var tickSteps = graph.width() / tradingGraph.axes.x2axis.numberTicks;
		graph.css('margin-left', '-' + (tickSteps / 2) + 'px');
	}
})();