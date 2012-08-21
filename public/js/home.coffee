(->
	onDomLoad = ->
		++domLoaded
		return	if domLoaded > 1
		$("#status-summary").tinyscrollbar
			axis: "x"
			scroll: false

		$("#trading-and-trending .graph-options").on "click", toggleGraphVisible

		# update the scrollable area on window resize
		$(window).on "resize", windowResize
		$(window).on "scroll", windowScroll

		# update counter
		$("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr "data-alerts", $(".protrada .alert-count").attr("data-alerts")

		# protrada video
		$("#watch-video").on("click"
			, ( e ) ->
				e.preventDefault()

				Panels.add(
					id: "protrada-video"
					url: "/panels/protrada-video"
					size: "mini"
					temporary: true
					extraClasses: "video"
					h1: "video intro"
					h2: "to domain trading"
					, true
				)
				return
			)		
			
		# TEMPORARY INSERT OF ALL MODULE PANELS
			
		$("#temp-list-forsale").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("list for sale")

				Panels.add(
					id: "moo"
					url: "/modules/home/panels/list-forsale"
					temporary: true
					h1: "list-forsale"
					h2: "moo in here"
					, true
				)
				return			
		)
			
		$("#temp-import-domains").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("import domains")

				Panels.add(
					id: "moo2"
					url: "/modules/home/panels/import-domains"
					temporary: true
					h1: "import-domains"
					h2: "moo in here"
					, true
				)
				return			 
		)		
			
		$("#temp-export-data").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("export data")

				Panels.add(
					id: "moo3"
					url: "/panels/export-data"
					temporary: true
					h1: "export-data"
					h2: "moo in here"
					, true
				)
				return				
		)
			
		$("#temp-protrada-video").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("protrada video")			

				Panels.add(
					id: "moo4"
					url: "/panels/protrada-video"
					temporary: true
					h1: "protrada-video"
					h2: "moo in here"
					, true
				)
				return			 
		)
		
		$("#temp-advanced-search").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("advanced search")						

				Panels.add(
					id: "moo5"
					url: "/panels/advanced-search"
					temporary: true
					h1: "advanced-search"
					h2: "moo in here"
					, true
				)
				return	 
		)
		
		$("#temp-domain-details").on("click"
			, ( e ) ->
				e.preventDefault()
				console.log("temp domain details")						

				Panels.add(
					id: "moo6"
					url: "/panels/domain-details"
					temporary: true
					h1: "temp-domain-details"
					h2: "moo in here"
					, true
				)
				return				
		)
					
		setupTradingGraph()
		return

	setupTradingGraph = ->
		return	if tradingGraph? or not $("#trading-and-trending .graph-container").is(":visible")
		createDateGraph("trading-graph"
			, [
				label: "Profit"
				lineColor: "#c4c4c4"
				fillColor: "#fff"
				markerColor: "#161413"
				data: [[new Date(2012, 0, 12), 9], [new Date(2012, 1, 12), 20], [new Date(2012, 2, 12), 10], [new Date(2012, 3, 12), 15]]
			,	
				label: "Sales"
				lineColor: "#5d8b10"
				fillColor: "#7fb91c"
				markerColor: "#3b6303"
				data: [[new Date(2012, 0, 12), 7], [new Date(2012, 1, 12), 17], [new Date(2012, 2, 12), 7], [new Date(2012, 3, 12), 12]]
			,	
				label: "Cost Price"
				lineColor: "#b2540c"
				fillColor: "#d66108"
				markerColor: "#753504"
				data: [[new Date(2012, 0, 12), 5], [new Date(2012, 1, 12), 7], [new Date(2012, 2, 12), 15], [new Date(2012, 3, 12), 7]]
			], "%s: <strong>$%s</strong>"
			, "1 month"
			, 300
		)
		return		
		
	onDomUnload = ->
		$(".ajax-spinner").show()
		$(window).off("resize", windowResize)
		$(window).off("scroll", windowScroll)
		$(".sectional-tabs").off("click", "li#watchlist", showWatchlist)
		$("#trading-and-trending .graph-options").off("click", toggleGraphVisible)
		if tradingGraph?
			tradingGraph.destroy()
			tradingGraph = null
			
		return

	# note that we don't bother deleting the tinyscrollbar, as it will be
	# removed when the DOM elements are.
	showWatchlist = ->
		togglePanel.call this, @id, getWatchlistContent
		return

	getWatchlistContent = ->
		"Watchlist content here"
		return

	toggleGraphVisible = ->
		container = $(this).closest("#trading-and-trending")
		if container.hasClass("graph-hidden")
			# show graph
			container.removeClass "graph-hidden"

			# initialize the graph if necessary
			setupTradingGraph()
		else
			container.addClass "graph-hidden"
		
		return			

	windowResize = ->
		width = $("#main-container").width()
		resizeScrollToWidth "#status-summary", width
		resizeScrollToWidth scrollContainer, width
		return		

	resizeScrollToWidth = (scrollSelector, containerWidth) ->
		scrollContainer = $(scrollSelector)
		scrollWidth = scrollContainer.width()
		scrollContainer.css width: containerWidth + "px"	unless containerWidth is scrollWidth
		scrollContainer.tinyscrollbar_update "relative"
		return		

	windowScroll = ->
	
	# thank heavens! nothing!
	createDateGraph = (elementId, settings, tooltipFormat, tickInterval, minWidthBetweenMarks) ->
		tooltipFormat = (if (typeof tooltipFormat is "undefined") then "%s: <strong>$%s</strong>" else tooltipFormat)
		tickInterval = (if (typeof tickInterval is "undefined") then "1 month" else tickInterval)
		minWidthBetweenMarks = (if (typeof minWidthBetweenMarks is "undefined") then 70 else minWidthBetweenMarks)
		parts = tickInterval.split(" ")
		tickIntervalParts = [parts[0], parts[1]]
		dataArray = []
		series = []
		dataMarks = settings[0].data.length
		graph = $("#" + elementId)
		containerWidth = graph.width()
		containerHeight = graph.height()

		# container for the graph so we can resize within the applicable
		# area as specified by the user
		graphContainer = $(document.createElement("div")).css(
			height: containerHeight
			overflow: "hidden"
		)
		graph.wrap(graphContainer)
		graphContainer = graph.parent()

		# scrolling area

		# recalculate the difference between the graph marks
		minWidthBetweenMarks = containerWidth / dataMarks	if minWidthBetweenMarks * dataMarks < containerWidth
		scrollContainer = $("<div class=\"tiny-scrollbar-horiz\" style=\"position: relative; width: " + containerWidth + "px; height: " + containerHeight + "px\"><div class=\"viewport\"><div class=\"overview\"></div></div></div>")
		graphContainer.wrap(scrollContainer)
		scrollContainer = graphContainer.closest(".tiny-scrollbar-horiz")
		$("<div class=\"scrollbar\"><div class=\"track\"><div class=\"thumb\"><div class=\"end\"></div></div></div></div>").prependTo scrollContainer

		# widen the graph area to be able to fit the whole graph
		containerWidth = minWidthBetweenMarks * dataMarks
		graph.css("width", containerWidth)
		graphContainer.closest(".overview").css("width", containerWidth)
		$(scrollContainer).tinyscrollbar(
			axis: "x"
			scroll: false
		)

		# resize the graph and shift it so that the first and last marks are
		# hidden
		graphContainer.css("width", containerWidth)
		graph.css(
			width: containerWidth + minWidthBetweenMarks
			marginLeft: -(minWidthBetweenMarks / 2)
		)

		set = 0

		while set < settings.length
			dataSet = []
			# calculations for going back / forward in a time interval
			first = settings[set].data[0]
			last = settings[set].data[settings[set].data.length - 1]
			newFirstDate = new $.jsDate(first[0].getTime()).add(-tickIntervalParts[0], tickIntervalParts[1])
			newLastDate = new $.jsDate(last[0].getTime()).add(tickIntervalParts[0], tickIntervalParts[1])

			# "back" 1 time interval
			dataSet.push([newFirstDate, first[1]])

			# all the intervals between
			valueIndex = 0

			while valueIndex < settings[set].data.length
				dataSet.push(settings[set].data[valueIndex])
				++valueIndex

			# "forward" 1 time interval
			dataSet.push([newLastDate, last[1]])
			dataArray.push(dataSet)

			# setup the series info to pass to jqplot
			series.push(
				label: settings[set].label
				color: settings[set].lineColor
				fillColor: settings[set].fillColor or settings[set].lineColor
				markerOptions:
					color: settings[set].markerColor or settings[set].lineColor
			)
			++set

		# minimum and maxium marks on the graph
		min = new Date(dataArray[0][0][0].getTime())
		max = new Date(dataArray[0][dataArray[0].length - 1][0].getTime())
		tradingGraph = $.jqplot(elementId, dataArray,
			stackSeries: false
			seriesDefaults:
				lineWidth: 5 # Width of the line in pixels.
				shadow: false # show shadow or not.
				fill: true # fill under the line,
				fillAndStroke: true # *stroke a line at top of fill area.
				fillAlpha: 0.85 # *custom alpha to apply to fillColor.
				xaxis: "x2axis"
				markerOptions:
					lineWidth: 2 # width of the stroke drawing the marker.
					size: 20 # size (diameter, edge length, etc.) of the marker.
					shadow: false # wether to draw shadow on marker or not.

			axesDefaults:
				tickOptions:
					showMark: false
					showGridline: false # wether to draw a gridline (across the whole grid) at this tick,
					showLabel: true # wether to show the text label at the tick,
					formatString: "" # format string to use with the axis tick formatter

			series: series
			axes:
				yaxis:
					# same options as axesDefaults
					show: false
					tickOptions:
						show: false
						showLabel: false # wether to show the text label at the tick,

					showTicks: false # wether or not to show the tick labels,
					showTickMarks: false # wether or not to show the tick marks

				xaxis:
					# same options as axesDefaults
					show: false
					tickOptions:
						show: false
						showLabel: false # wether to show the text label at the tick,

					showTicks: false # wether or not to show the tick labels,
					showTickMarks: false # wether or not to show the tick marks

				x2axis:
					renderer: $.jqplot.DateAxisRenderer
					tickOptions:
						formatString: "%b, %e"

					min: min
					max: max
					tickInterval: tickInterval

			gridPadding:
				left: 0
				right: 0
				bottom: 0

			grid:
				drawGridLines: false # wether to draw lines across the grid or not.
				borderWidth: 0 # pixel width of border around grid.
				shadow: false # draw a shadow for grid.

			highlighter:
				show: true
				sizeAdjust: 2 # pixels to add to the size of filled markers when drawing highlight.
				showTooltip: true # show a tooltip with data point values.
				tooltipLocation: "s" # location of tooltip: n, ne, e, se, s, sw, w, nw.
				fadeTooltip: true # use fade effect to show/hide tooltip.
				tooltipFadeSpeed: "100" # slow, def, fast, or a number of milliseconds.
				tooltipOffset: 8 # pixel offset of tooltip from the highlight.
				useAxesFormatters: true # use the same format string and formatters as used in the axes to
				tooltipAxes: "y" # which axis values to display in the tooltip, x, y or both.
				tooltipContentEditor: (str, seriesIndex, pointIndex) ->
					$.jqplot.sprintf tooltipFormat, tradingGraph.series[seriesIndex].label, tradingGraph.data[seriesIndex][pointIndex][1].toMoney()
		)

		# shift the graph so the dots aren't visible on the left hand side
		tickSteps = graph.width() / tradingGraph.axes.x2axis.numberTicks
		graph.css "margin-left", "-" + (tickSteps / 2) + "px"
		return

	domLoaded = 0
	tradingGraph = null
	scrollContainer = undefined
	$("#main-container").one(ajaxUnload: onDomUnload)
	onDomLoad()
	$(document).on("click"
		, "#toggle-side-bar, #x-side-bar"
		, (e) ->
			windowResize()
			return
	)

	return
)()
