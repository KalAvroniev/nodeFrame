// Generated by CoffeeScript 1.3.3
/*
Example usage:

$("#grid-view").grid({
	url: "uri/to/grid/data", // ajax endpoint for grid data
	data: [], // use this array of data for the grid instead of ajaxing it in
	type: "detailed", // is this grid detailed or simple
	stickyHeader: true, // utilise the sticky header
	fakeScrollbars: true // utilise fake scrollbars for table navigation
});
*/

var Grid;

Grid = function(element, options) {
  this.grid = $(element);
  this.options = {
    url: null,
    data: null,
    type: "detailed",
    stickyHeader: false,
    fakeScrollbars: false
  };
  $.extend(this.options, options);
  this.init();
};

Grid.prototype = {
  constructor: Grid,
  isWaiting: false,
  rowOffset: 0,
  init: function() {
    var $grid, that;
    that = this;
    $grid = this.grid;
    $.jsonrpc(this.options.url, {
      offset: this.rowOffset
    }, function(data) {
      $.jade.getTemplate("grid/table", function() {
        $grid.html($.jade.renderSync("views_grid_table", data, that.jadeError));
        $.jade.getTemplate("grid/row", function() {
          var actions, i, records;
          records = data.records;
          actions = data.actions;
          i = 0;
          while (i < records.length) {
            records[i].actions = actions;
            $grid.find("tbody").append($.jade.renderSync("views_grid_row", records[i], that.jadeError));
            ++i;
          }
          $grid.find("tfoot").attr("hidden", true);
          that.setup();
        });
      });
      that.rowOffset += 10;
    });
  },
  setup: function() {
    var that;
    that = this;
    /*
    		TODO: will this ever be needed again?
    		$( document.body ).not(".mobile").find(".domain-title").on({
    			mouseenter: this.domainTitleMouseEnter,
    			mouseleave: this.domainTitleMouseLeave
    		});
    */

    $("#main-container").on("click", ".grid-table .sticky", {
      grid: this
    }, this.toggleSticky);
    this.grid.find("tbody").on("click", "tr:not(.parent-open, .child)", this.expandRow).on("click", ".parent-open, .child", this.collapseRow);
    $(".grid-table").find("tbody").on("click", ".domain-title-cntnr .copy-to-clipboard", function(e) {
      e.preventDefault();
    }).on("click", "td button.favourite", this.toggleFavourite).on("click", "td button.select", {
      grid: this
    }, this.toggleSelect).on("click", "td.actions a", function(e) {
      var $panelTabs, $tabClone, $this, panelId;
      e.preventDefault();
      e.stopPropagation();
      $this = $(this);
      panelId = $this.data("panel-id");
      $panelTabs = $("header#main").find(".sectional-tabs");
      $tabClone = $panelTabs.find(".standout-tab").clone().attr("id", panelId).addClass("temporary-panel-tab").removeClass("standout-tab");
      $tabClone.find("a").attr("href", "javascript:$.app.panel.show( '/panels/protrada-video', {tabid: '" + panelId + "', panel_size: 'mini-panel', temporary: true} );").html("<strong>domain details</strong> something here").end().prependTo($panelTabs);
      $.app.panel.show("/panels/" + panelId, {
        tabid: panelId,
        panel_size: "mini-panel",
        temporary: true
      });
    });
    $(window).on("resize", {
      grid: this
    }, this.windowResize).on("scroll", {
      grid: this
    }, this.windowScroll);
    this.grid.on("scroll.tinyscrollbar", ".scrollbar", {
      grid: this
    }, this.updateTableHeaders);
    if (this.options.stickyHeader) {
      this.cloneTableHead();
    }
    $(".grid-table").find("thead").find(".filter").on("click", ".select", {
      grid: this
    }, this.bulkActionsHandler).on("click", ".favourite", {
      grid: this
    }, this.bulkFavouritesHandler);
    if (this.bottomOfTable() >= 0) {
      this.grid.before("<a href=\"javascript:$('#grid-view').grid('loadInData');\">Load more data</a>");
    }
    Scrollbars.add("grid", this.grid, {
      axis: "x",
      scroll: false
    });
    this.windowResize();
    this.__tempAdvancedSearch();
  },
  teardown: function() {},
  jadeError: function(error) {
    alert("jadeError-> " + error);
  },
  __tempAdvancedSearch: function() {
    $("#advanced-keyword-filter").on("click", function(e) {
      var $panelTabs, $tabClone;
      $panelTabs = $("header#main").find(".sectional-tabs");
      $tabClone = $panelTabs.find(".standout-tab").clone().attr("id", "advanced-search").addClass("temporary-panel-tab").removeClass("standout-tab");
      e.preventDefault();
      $tabClone.find("a").attr("href", "javascript:$.app.panel.show( '/panels/advanced-search', {tabid: 'advanced-search', panel_size: 'mini-panel video', temporary: true} );").html("<strong>advanced search</strong> something here").end().prependTo($panelTabs);
      $.app.panel.show("/panels/advanced-search", {
        tabid: "advanced-search",
        panel_size: "mini-panel",
        temporary: true
      });
    });
  },
  /*
  	cloneTableHead
  */

  cloneTableHead: function() {
    var firstDataRow, table, tbody, thead, viewport;
    table = this.grid.find("table");
    thead = table.find("thead");
    tbody = table.find("tbody");
    viewport = table.parent();
    firstDataRow = tbody.find("tr").not(".not-data").first();
    this.grid.addClass("tiny-scrollbar-horiz");
    table.addClass("floatable");
    thead.addClass("tableFloatingHeaderOriginal");
    if (viewport.css("position") === "relative") {
      viewport.addClass("divTableWithFloatingHeader");
    } else {
      table.wrap("<div class=\"divTableWithFloatingHeader\" style=\"position: relative;\" />");
    }
    $("#thetableclone").find("table").addClass("tableFloatingHeader").find("thead").html(thead.html()).next("tbody").html(firstDataRow.html()).end().end().end().css({
      top: $("#main").height(),
      height: thead.height()
    });
  },
  expandRow: function() {
    var $row;
    $row = $(this);
    $row.siblings(".parent-open").trigger("click");
    $row.addClass("row-sel parent-open").after("<tr class=\"row-sel child\" style=\"display: none;\"><td colspan=\"" + $row.find("td").length + "\"><div class=\"child-inner\"> <a class=\"x-row-sel\" href=\"javascript:void(0);\">x</a><p><strong>selected domain content</strong> <br />to be placed in here &hellip;</p></div></td></tr>").next().fadeIn();
  },
  collapseRow: function() {
    var $row;
    $row = $(this);
    if ($row.hasClass("child")) {
      $row.fadeOut(function() {
        $row.prev().removeClass("row-sel parent-open").end().remove();
      });
    } else {
      $row.next().fadeOut(function() {
        $row.removeClass("row-sel parent-open").next().remove();
      });
    }
  },
  bulkActionsHandler: function(e) {
    var checking, grid, isClone;
    grid = (e ? e.data.grid : this);
    checking = !$(this).hasClass("active");
    isClone = $(this).closest("table").parent().is("#thetableclone");
    if (checking) {
      $(".btn.select", grid.grid.find("tbody")).each(function() {
        $(this).addClass("active");
      });
      if (!isClone) {
        $("#thetableclone .fav-sel-all .btn.select").addClass("active");
      } else {
        grid.grid.find(".fav-sel-all .btn.select").addClass("active");
      }
    } else {
      $(".btn.select", grid.grid.find("tbody")).each(function() {
        $(this).removeClass("active");
      });
      if (!isClone) {
        $("#thetableclone .fav-sel-all .btn.select").removeClass("active");
      } else {
        grid.grid.find(".fav-sel-all .btn.select").removeClass("active");
      }
    }
    grid.toggleBulkHandler(e);
  },
  bulkFavouritesHandler: function(e) {
    var checking, grid, isClone;
    grid = (e ? e.data.grid : this);
    checking = !$(this).hasClass("active");
    isClone = $(this).closest("table").parent().is("#thetableclone");
    if (checking) {
      $(".btn.favourite", grid.grid.find("tbody")).each(function() {
        $(this).addClass("active");
      });
      if (!isClone) {
        $("#thetableclone .fav-sel-all .btn.favourite").addClass("active");
      } else {
        grid.grid.find(".fav-sel-all .btn.favourite").addClass("active");
      }
    } else {
      $(".btn.favourite", grid.grid.find("tbody")).each(function() {
        $(this).removeClass("active");
      });
      if (!isClone) {
        $("#thetableclone .fav-sel-all .btn.favourite").removeClass("active");
      } else {
        grid.grid.find(".fav-sel-all .btn.favourite").removeClass("active");
      }
    }
  },
  toggleSticky: function(e) {
    var grid;
    grid = (e ? e.data.grid : this);
    e.preventDefault();
    grid.options.stickyHeader = !grid.options.stickyHeader;
    grid.grid.find(".sticky").find("span").toggleClass("on off");
    $(document.body).toggleClass("sticky-thead");
    grid.updateTableHeaders();
  },
  toggleFavourite: function(e) {
    e.preventDefault();
    e.stopPropagation();
    $(this).button("toggle");
  },
  toggleBulkHandler: function(e) {
    var $tr, grid, selected;
    grid = (e ? e.data.grid : this);
    $tr = $(".bulk-actions").parent();
    selected = $(".btn.select", grid.grid.find("tbody")).filter(".active").length;
    if ($tr.is(":visible") && !selected) {
      $tr.fadeOut(function() {
        $("#thetableclone").height(grid.grid.find("thead").height());
      }).attr("hidden");
    } else {
      $("#thetableclone").height(500);
      $tr.fadeIn(function() {
        $("#thetableclone").height(grid.grid.find("thead").height());
      }).removeAttr("hidden");
    }
  },
  toggleSelect: function(e) {
    var grid;
    grid = (e ? e.data.grid : this);
    e.preventDefault();
    e.stopPropagation();
    $(this).button("toggle");
    grid.toggleBulkHandler(e);
  },
  domainTitleMouseEnter: function() {
    $(this).find(".domain-title-cntnr .copy-to-clipboard").css("opacity", 1);
  },
  domainTitleMouseLeave: function() {
    $(this).find(".domain-title-cntnr .copy-to-clipboard").css("opacity", 0);
  },
  windowResize: function(e) {
    var adjustedWidth, grid, spanContainerPadding;
    grid = (e ? e.data.grid : this);
    spanContainerPadding = parseInt(grid.grid.find("thead").find(".container").first().css("padding-left"), 10);
    adjustedWidth = $("#main-container").width() - (2 * spanContainerPadding);
    Scrollbars.update("grid");
    grid.grid.add("#thetableclone").find("thead, tbody").find(".container > span").width(adjustedWidth);
    grid.positionHorizScroll();
    grid.updateTableHeaders();
  },
  windowScroll: function(e) {
    var grid;
    grid = e.data.grid;
    $(".btn-group.open").removeClass("open");
    grid.positionHorizScroll();
    grid.updateTableHeaders();
    if (!grid.isWaiting && grid.distanceFromBottom() <= 150) {
      grid.isWaiting = true;
      grid.loadInData();
    }
  },
  bottomOfTable: function() {
    var $viewport, $window;
    $window = $(window);
    $viewport = $(".viewport", this.grid);
    return ($window.scrollTop() + $window.height()) - ($viewport.offset().top + $viewport.height());
  },
  loadInData: function() {
    var $grid, that;
    that = this;
    $grid = this.grid;
    $grid.find("tfoot").removeAttr("hidden");
    $.jsonrpc(this.options.url, {
      offset: this.rowOffset
    }, function(data) {
      $.jade.getTemplate("grid/row", function() {
        var actions, i, records;
        records = data.records;
        actions = data.actions;
        i = 0;
        while (i < records.length) {
          records[i].actions = actions;
          $grid.find("tbody").append($.jade.renderSync("views_grid_row", records[i], that.jadeError));
          ++i;
        }
        $grid.find("tfoot").attr("hidden", true);
        that.isWaiting = false;
      });
      that.rowOffset += 10;
    });
  },
  distanceFromBottom: function() {
    return $(document).height() - ($(window).scrollTop() + $(window).height());
  },
  isTableOnScreen: function(offset) {
    var bottomOfScreen, tableOffset;
    bottomOfScreen = $(window).scrollTop() + $(window).height();
    tableOffset = $(".viewport", this.grid).offset().top;
    offset = offset || 0;
    return bottomOfScreen - (tableOffset + offset) >= 0;
  },
  positionHorizScroll: function() {
    $(".scrollbar", this.grid).css("display", (this.isTableOnScreen() ? "block" : "none"));
  },
  updateTableHeaders: function(e) {
    var that;
    that = (e ? e.data.grid : this);
    $(".divTableWithFloatingHeader", that.grid).each(function() {
      var body, offset, scrollTop, theCloneContainer, theCloneTable, viewport;
      theCloneTable = $(".tableFloatingHeader");
      theCloneContainer = theCloneTable.closest("#thetableclone");
      body = $(document.body);
      if (!that.options.stickyHeader) {
        theCloneContainer.css("display", "none");
        if (body.hasClass("sticky-thead")) {
          body.removeClass("sticky-thead");
        }
        return;
      }
      offset = $(".grid-table", that.grid).offset().top;
      scrollTop = $(window).scrollTop();
      viewport = $(that.grid);
      if ((scrollTop + $("header#main").height()) - offset > 0) {
        theCloneContainer.css("display", "block");
        if (!body.hasClass("sticky-thead")) {
          body.addClass("sticky-thead");
        }
      } else {
        theCloneContainer.css("display", "none");
        if (body.hasClass("sticky-thead")) {
          body.removeClass("sticky-thead");
        }
      }
      theCloneTable.css({
        left: -Scrollbars.offset("grid") + "px"
      });
      theCloneContainer.width(viewport.width());
    });
  }
};

$.fn.grid = function(option) {
  return this.each(function() {
    var $this, data;
    $this = $(this);
    data = $this.data("grid");
    if (!data) {
      $this.data("grid", (data = new Grid(this, option)));
    }
    if (typeof option === "string") {
      data[option]();
    }
  });
};
