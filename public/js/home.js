// Generated by CoffeeScript 1.3.3
(function() {

  (function() {
    var createDateGraph, domLoaded, getWatchlistContent, onDomLoad, onDomUnload, resizeScrollToWidth, scrollContainer, setupTradingGraph, showWatchlist, toggleGraphVisible, tradingGraph, windowResize, windowScroll;
    onDomLoad = function() {
      ++domLoaded;
      if (domLoaded > 1) {
        return;
      }
      $("#status-summary").tinyscrollbar({
        axis: "x",
        scroll: false
      });
      $("#trading-and-trending .graph-options").on("click", toggleGraphVisible);
      $(window).on("resize", windowResize);
      $(window).on("scroll", windowScroll);
      $("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr("data-alerts", $(".protrada .alert-count").attr("data-alerts"));
      $("#watch-video").on("click", function(e) {
        e.preventDefault();
        console.log("watch video");
        Panels.add({
          id: "protrada-video",
          url: "/panels/protrada-video",
          size: "mini",
          temporary: true,
          extraClasses: "video",
          h1: "video intro",
          h2: "to domain trading"
        }, true);
      });
      $("#temp-list-forsale").on("click", function(e) {
        e.preventDefault();
        console.log("list for sale");
        Panels.add({
          id: "list-forsale",
          url: "/modules/home/panels/list-forsale",
          temporary: true,
          h1: "list-forsale",
          h2: "moo in here"
        }, true);
      });
      $("#temp-import-domains").on("click", function(e) {
        e.preventDefault();
        console.log("import domains");
        Panels.add({
          id: "import-domains",
          url: "/modules/home/panels/import-domains",
          temporary: true,
          h1: "import-domains",
          h2: "moo in here"
        }, true);
      });
      $("#temp-export-data").on("click", function(e) {
        e.preventDefault();
        console.log("export data");
        Panels.add({
          id: "export-data",
          url: "/panels/export-data",
          temporary: true,
          h1: "export-data",
          h2: "moo in here"
        }, true);
      });
      $("#temp-protrada-video").on("click", function(e) {
        e.preventDefault();
        console.log("protrada video");
        Panels.add({
          id: "temp-protrada-video",
          url: "/panels/protrada-video",
          temporary: true,
          h1: "protrada-video",
          h2: "moo in here"
        }, true);
      });
      $("#temp-advanced-search").on("click", function(e) {
        e.preventDefault();
        console.log("advanced search");
        Panels.add({
          id: "advanced-search",
          url: "/panels/advanced-search",
          temporary: true,
          h1: "advanced-search",
          h2: "moo in here"
        }, true);
      });
      setupTradingGraph();
    };
    setupTradingGraph = function() {
      if ((typeof tradingGraph !== "undefined" && tradingGraph !== null) || !$("#trading-and-trending .graph-container").is(":visible")) {
        return;
      }
      createDateGraph("trading-graph", [
        {
          label: "Profit",
          lineColor: "#c4c4c4",
          fillColor: "#fff",
          markerColor: "#161413",
          data: [[new Date(2012, 0, 12), 9], [new Date(2012, 1, 12), 20], [new Date(2012, 2, 12), 10], [new Date(2012, 3, 12), 15]]
        }, {
          label: "Sales",
          lineColor: "#5d8b10",
          fillColor: "#7fb91c",
          markerColor: "#3b6303",
          data: [[new Date(2012, 0, 12), 7], [new Date(2012, 1, 12), 17], [new Date(2012, 2, 12), 7], [new Date(2012, 3, 12), 12]]
        }, {
          label: "Cost Price",
          lineColor: "#b2540c",
          fillColor: "#d66108",
          markerColor: "#753504",
          data: [[new Date(2012, 0, 12), 5], [new Date(2012, 1, 12), 7], [new Date(2012, 2, 12), 15], [new Date(2012, 3, 12), 7]]
        }
      ], "%s: <strong>$%s</strong>", "1 month", 300);
    };
    onDomUnload = function() {
      var tradingGraph;
      $(".ajax-spinner").show();
      $(window).off("resize", windowResize);
      $(window).off("scroll", windowScroll);
      $(".sectional-tabs").off("click", "li#watchlist", showWatchlist);
      $("#trading-and-trending .graph-options").off("click", toggleGraphVisible);
      if (typeof tradingGraph !== "undefined" && tradingGraph !== null) {
        tradingGraph.destroy();
        tradingGraph = null;
      }
    };
    showWatchlist = function() {
      togglePanel.call(this, this.id, getWatchlistContent);
    };
    getWatchlistContent = function() {
      "Watchlist content here";

    };
    toggleGraphVisible = function() {
      var container;
      container = $(this).closest("#trading-and-trending");
      if (container.hasClass("graph-hidden")) {
        container.removeClass("graph-hidden");
        setupTradingGraph();
      } else {
        container.addClass("graph-hidden");
      }
    };
    windowResize = function() {
      var width;
      width = $("#main-container").width();
      resizeScrollToWidth("#status-summary", width);
      resizeScrollToWidth(scrollContainer, width);
    };
    resizeScrollToWidth = function(scrollSelector, containerWidth) {
      var scrollContainer, scrollWidth;
      scrollContainer = $(scrollSelector);
      scrollWidth = scrollContainer.width();
      if (containerWidth !== scrollWidth) {
        scrollContainer.css({
          width: containerWidth + "px"
        });
      }
      scrollContainer.tinyscrollbar_update("relative");
    };
    windowScroll = function() {};
    createDateGraph = function(elementId, settings, tooltipFormat, tickInterval, minWidthBetweenMarks) {
      var containerHeight, containerWidth, dataArray, dataMarks, dataSet, first, graph, graphContainer, last, max, min, newFirstDate, newLastDate, parts, scrollContainer, series, set, tickIntervalParts, tickSteps, tradingGraph, valueIndex;
      tooltipFormat = (typeof tooltipFormat === "undefined" ? "%s: <strong>$%s</strong>" : tooltipFormat);
      tickInterval = (typeof tickInterval === "undefined" ? "1 month" : tickInterval);
      minWidthBetweenMarks = (typeof minWidthBetweenMarks === "undefined" ? 70 : minWidthBetweenMarks);
      parts = tickInterval.split(" ");
      tickIntervalParts = [parts[0], parts[1]];
      dataArray = [];
      series = [];
      dataMarks = settings[0].data.length;
      graph = $("#" + elementId);
      containerWidth = graph.width();
      containerHeight = graph.height();
      graphContainer = $(document.createElement("div")).css({
        height: containerHeight,
        overflow: "hidden"
      });
      graph.wrap(graphContainer);
      graphContainer = graph.parent();
      if (minWidthBetweenMarks * dataMarks < containerWidth) {
        minWidthBetweenMarks = containerWidth / dataMarks;
      }
      scrollContainer = $("<div class=\"tiny-scrollbar-horiz\" style=\"position: relative; width: " + containerWidth + "px; height: " + containerHeight + "px\"><div class=\"viewport\"><div class=\"overview\"></div></div></div>");
      graphContainer.wrap(scrollContainer);
      scrollContainer = graphContainer.closest(".tiny-scrollbar-horiz");
      $("<div class=\"scrollbar\"><div class=\"track\"><div class=\"thumb\"><div class=\"end\"></div></div></div></div>").prependTo(scrollContainer);
      containerWidth = minWidthBetweenMarks * dataMarks;
      graph.css("width", containerWidth);
      graphContainer.closest(".overview").css("width", containerWidth);
      $(scrollContainer).tinyscrollbar({
        axis: "x",
        scroll: false
      });
      graphContainer.css("width", containerWidth);
      graph.css({
        width: containerWidth + minWidthBetweenMarks,
        marginLeft: -(minWidthBetweenMarks / 2)
      });
      set = 0;
      while (set < settings.length) {
        dataSet = [];
        first = settings[set].data[0];
        last = settings[set].data[settings[set].data.length - 1];
        newFirstDate = new $.jsDate(first[0].getTime()).add(-tickIntervalParts[0], tickIntervalParts[1]);
        newLastDate = new $.jsDate(last[0].getTime()).add(tickIntervalParts[0], tickIntervalParts[1]);
        dataSet.push([newFirstDate, first[1]]);
        valueIndex = 0;
        while (valueIndex < settings[set].data.length) {
          dataSet.push(settings[set].data[valueIndex]);
          ++valueIndex;
        }
        dataSet.push([newLastDate, last[1]]);
        dataArray.push(dataSet);
        series.push({
          label: settings[set].label,
          color: settings[set].lineColor,
          fillColor: settings[set].fillColor || settings[set].lineColor,
          markerOptions: {
            color: settings[set].markerColor || settings[set].lineColor
          }
        });
        ++set;
      }
      min = new Date(dataArray[0][0][0].getTime());
      max = new Date(dataArray[0][dataArray[0].length - 1][0].getTime());
      tradingGraph = $.jqplot(elementId, dataArray, {
        stackSeries: false,
        seriesDefaults: {
          lineWidth: 5,
          shadow: false,
          fill: true,
          fillAndStroke: true,
          fillAlpha: 0.85,
          xaxis: "x2axis",
          markerOptions: {
            lineWidth: 2,
            size: 20,
            shadow: false
          }
        },
        axesDefaults: {
          tickOptions: {
            showMark: false,
            showGridline: false,
            showLabel: true,
            formatString: ""
          }
        },
        series: series,
        axes: {
          yaxis: {
            show: false,
            tickOptions: {
              show: false,
              showLabel: false
            },
            showTicks: false,
            showTickMarks: false
          },
          xaxis: {
            show: false,
            tickOptions: {
              show: false,
              showLabel: false
            },
            showTicks: false,
            showTickMarks: false
          },
          x2axis: {
            renderer: $.jqplot.DateAxisRenderer,
            tickOptions: {
              formatString: "%b, %e"
            },
            min: min,
            max: max,
            tickInterval: tickInterval
          }
        },
        gridPadding: {
          left: 0,
          right: 0,
          bottom: 0
        },
        grid: {
          drawGridLines: false,
          borderWidth: 0,
          shadow: false
        },
        highlighter: {
          show: true,
          sizeAdjust: 2,
          showTooltip: true,
          tooltipLocation: "s",
          fadeTooltip: true,
          tooltipFadeSpeed: "100",
          tooltipOffset: 8,
          useAxesFormatters: true,
          tooltipAxes: "y",
          tooltipContentEditor: function(str, seriesIndex, pointIndex) {
            return $.jqplot.sprintf(tooltipFormat, tradingGraph.series[seriesIndex].label, tradingGraph.data[seriesIndex][pointIndex][1].toMoney());
          }
        }
      });
      tickSteps = graph.width() / tradingGraph.axes.x2axis.numberTicks;
      graph.css("margin-left", "-" + (tickSteps / 2) + "px");
    };
    domLoaded = 0;
    tradingGraph = null;
    scrollContainer = void 0;
    $("#main-container").one({
      ajaxUnload: onDomUnload
    });
    onDomLoad();
    $(document).on("click", "#toggle-side-bar, #x-side-bar", function(e) {
      windowResize();
    });
  })();

}).call(this);
