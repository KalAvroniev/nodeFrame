#
#$("#grid-view").grid({
#    url: "uri/to/grid/data", // ajax endpoint for grid data
#	data: [], // use this array of data for the grid instead of ajaxing it in
#	type: "detailed", // is this grid detailed or simple
#	stickyHeader: true, // utilise the sticky header
#	fakeScrollbars: true // utilise fake scrollbars for table navigation
#});
#
Grid = (element, options) ->
  @grid = $(element)
  @options =
    url: null # ajax endpoint for grid data
    data: null # use this array of data for the grid instead of ajaxing it in
    type: "detailed" # is this grid detailed or simple
    stickyHeader: false # utilise the sticky header
    fakeScrollbars: false # utilise fake scrollbars for table navigation

  $.extend @options, options
  @init()

Grid:: =
  constructor: Grid
  isWaiting: false # used by the scroll listener to load new content
  rowOffset: 0
  init: ->
    that = this
    $grid = @grid
    $.jsonrpc @options.url,
      offset: @rowOffset
    , (data) ->
      $.jade.getTemplate "grid/table", ->
        $grid.html $.jade.renderSync("views_grid_table", data, that.jadeError)
        $.jade.getTemplate "grid/row", ->
          records = data.records
          actions = data.actions
          i = 0

          while i < records.length
            
            # push actions onto records
            records[i].actions = actions
            $grid.find("tbody").append $.jade.renderSync("views_grid_row", records[i], that.jadeError)
            ++i
          
          # hide spinner
          $grid.find("tfoot").attr "hidden", true
          
          # run setup
          that.setup()


      that.rowOffset += 10


  setup: ->
    that = this
    
    # TODO: will this ever be needed again?
    #$( document.body ).not(".mobile").find(".domain-title").on({
    #			mouseenter: this.domainTitleMouseEnter,
    #			mouseleave: this.domainTitleMouseLeave
    #		});
    $("#main-container").on "click", ".grid-table .sticky",
      grid: this
    , @toggleSticky
    @grid.find("tbody").on("click", "tr:not(.parent-open, .child)", @expandRow).on "click", ".parent-open, .child", @collapseRow
    $(".grid-table").find("tbody").on("click", ".domain-title-cntnr .copy-to-clipboard", (e) ->
      e.preventDefault()
    ).on("click", "td button.favourite", @toggleFavourite).on("click", "td button.select",
      grid: this
    , @toggleSelect).on "click", "td.actions a", (e) ->
      e.preventDefault()
      e.stopPropagation()
      $this = $(this)
      panelId = $this.data("panel-id")
      $panelTabs = $("header#main").find(".sectional-tabs")
      $tabClone = $panelTabs.find(".standout-tab").clone().attr("id", panelId).addClass("temporary-panel-tab").removeClass("standout-tab")
      $tabClone.find("a").attr("href", "javascript:$.pv3.panel.show( '/panels/protrada-video', {tabid: '" + panelId + "', panel_size: 'mini-panel', temporary: true} );").html("<strong>domain details</strong> something here").end().prependTo $panelTabs
      $.pv3.panel.show "/panels/" + panelId,
        tabid: panelId
        panel_size: "mini-panel"
        temporary: true


    $(window).on("resize",
      grid: this
    , @windowResize).on "scroll",
      grid: this
    , @windowScroll
    @grid.on "scroll.tinyscrollbar", ".scrollbar",
      grid: this
    , @updateTableHeaders
    
    # clone the <thead> if requested
    @cloneTableHead()  if @options.stickyHeader
    $(".grid-table").find("thead").find(".filter").on("click", ".select",
      grid: this
    , @bulkActionsHandler).on "click", ".favourite",
      grid: this
    , @bulkFavouritesHandler
    
    # scroll event won't fire lazy load, as there isn't a scrollbar!
    
    #this.loadInData();
    @grid.before "<a href=\"javascript:$('#grid-view').grid('loadInData');\">Load more data</a>"  if @bottomOfTable() >= 0
    Scrollbars.add "grid", @grid,
      axis: "x"
      scroll: false

    @windowResize()
    
    # TODO: must get rid of this, place into a nicer handler
    @__tempAdvancedSearch()

  
  # this function isn't used yet, will be once the
  # page load/unload handlers are properly fleshed out
  teardown: ->

  
  #$("div.divTableWithFloatingHeader").remove();
  #
  #		$( document.body ).not(".mobile").find("td.domain-title").off({
  #			mouseenter: domainTitleMouseEnter,
  #			mouseleave: domainTitleMouseLeave
  #		});
  #
  #		$("#main-container").off("click", ".grid-table th.sticky", toggleSticky);
  #
  #		$(".grid-table").children("tbody").off( "click", ".domain-title-cntnr .copy-to-clipboard", preventEvent )
  #			.off( "click", "td button.favourite", toggleFavourite )
  #			.off( "click", "td button.select", toggleSelect );
  #
  #		$( window ).off( "resize", windowResize ).off( "scroll", windowScroll );
  #		$( verticalScroll + ", " + horizontalScroll ).off( "resize", copyHeaderSize );
  #		$( horizontalScroll ).off( "tsb_scroll", horizontalScroll + " > .scrollbar", UpdateTableHeaders );
  #
  #		if ( typeof exchangeDomainResults !== "undefined" ) {
  #			exchangeDomainResults = null;
  #		}
  
  # TODO: really, really, really need to get rid of this
  # can't believe Jade wouldn't have an in-built alternative
  jadeError: (error) ->
    alert "jadeError-> " + error

  
  # TODO: refactor this, not DRY compliant
  __tempAdvancedSearch: ->
    $("#advanced-keyword-filter").on "click", (e) ->
      $panelTabs = $("header#main").find(".sectional-tabs")
      $tabClone = $panelTabs.find(".standout-tab").clone().attr("id", "advanced-search").addClass("temporary-panel-tab").removeClass("standout-tab")
      e.preventDefault()
      $tabClone.find("a").attr("href", "javascript:$.pv3.panel.show( '/panels/advanced-search', {tabid: 'advanced-search', panel_size: 'mini-panel video', temporary: true} );").html("<strong>advanced search</strong> something here").end().prependTo $panelTabs
      $.pv3.panel.show "/panels/advanced-search",
        tabid: "advanced-search"
        panel_size: "mini-panel"
        temporary: true



  
  ###
  cloneTableHead
  ###
  cloneTableHead: ->
    table = @grid.find("table")
    thead = table.find("thead")
    tbody = table.find("tbody")
    viewport = table.parent()
    firstDataRow = tbody.find("tr").not(".not-data").first()
    
    # TODO: what function does this class provide?
    @grid.addClass "tiny-scrollbar-horiz"
    
    # TODO: these classes aren't really useful, remove/replace?
    table.addClass "floatable"
    thead.addClass "tableFloatingHeaderOriginal"
    
    # TODO: is this redundant?
    if viewport.css("position") is "relative"
      viewport.addClass "divTableWithFloatingHeader"
    else
      table.wrap "<div class=\"divTableWithFloatingHeader\" style=\"position: relative;\" />" # not a huge fan of breaking the separation of concerns...
    
    # "clone" the relevant elements (html() method is waaaay more performant than clone())
    # TODO: is this class needed too?
    # "cloning" a row keeps the widths of the <th>'s the same
    $("#thetableclone").find("table").addClass("tableFloatingHeader").find("thead").html(thead.html()).next("tbody").html(firstDataRow.html()).end().end().end().css
      top: $("#main").height() # position the table clone under the <header>
      height: thead.height() # "hide" the cloned <tbody> so click events can "pass-through" to the actual <tbody>


  expandRow: ->
    $row = $(this)
    
    # collapse any other open rows
    $row.siblings(".parent-open").trigger "click"
    $row.addClass("row-sel parent-open").after("<tr class=\"row-sel child\" style=\"display: none;\"><td colspan=\"" + $row.find("td").length + "\"><div class=\"child-inner\"> <a class=\"x-row-sel\" href=\"javascript:void(0);\">x</a><p><strong>selected domain content</strong> <br />to be placed in here &hellip;</p></div></td></tr>").next().fadeIn()

  collapseRow: ->
    $row = $(this)
    if $row.hasClass("child")
      $row.fadeOut ->
        $row.prev().removeClass("row-sel parent-open").end().remove()

    else
      $row.next().fadeOut ->
        $row.removeClass("row-sel parent-open").next().remove()


  bulkActionsHandler: (e) ->
    grid = (if e then e.data.grid else this)
    checking = not $(this).hasClass("active")
    isClone = $(this).closest("table").parent().is("#thetableclone")
    
    # TODO: not DRY compliant
    if checking
      $(".btn.select", grid.grid.find("tbody")).each ->
        $(this).addClass "active"

      unless isClone
        $("#thetableclone .fav-sel-all .btn.select").addClass "active"
      else
        grid.grid.find(".fav-sel-all .btn.select").addClass "active"
    else
      $(".btn.select", grid.grid.find("tbody")).each ->
        $(this).removeClass "active"

      unless isClone
        $("#thetableclone .fav-sel-all .btn.select").removeClass "active"
      else
        grid.grid.find(".fav-sel-all .btn.select").removeClass "active"
    grid.toggleBulkHandler e

  bulkFavouritesHandler: (e) ->
    grid = (if e then e.data.grid else this)
    checking = not $(this).hasClass("active")
    isClone = $(this).closest("table").parent().is("#thetableclone")
    
    # TODO: not DRY compliant
    if checking
      $(".btn.favourite", grid.grid.find("tbody")).each ->
        $(this).addClass "active"

      unless isClone
        $("#thetableclone .fav-sel-all .btn.favourite").addClass "active"
      else
        grid.grid.find(".fav-sel-all .btn.favourite").addClass "active"
    else
      $(".btn.favourite", grid.grid.find("tbody")).each ->
        $(this).removeClass "active"

      unless isClone
        $("#thetableclone .fav-sel-all .btn.favourite").removeClass "active"
      else
        grid.grid.find(".fav-sel-all .btn.favourite").removeClass "active"

  toggleSticky: (e) ->
    grid = (if e then e.data.grid else this)
    e.preventDefault()
    grid.options.stickyHeader = not grid.options.stickyHeader
    grid.grid.find(".sticky").find("span").toggleClass "on off"
    $(document.body).toggleClass "sticky-thead"
    grid.updateTableHeaders()

  toggleFavourite: (e) ->
    e.preventDefault()
    e.stopPropagation()
    $(this).button "toggle"

  toggleBulkHandler: (e) ->
    grid = (if e then e.data.grid else this)
    $tr = $(".bulk-actions").parent()
    selected = $(".btn.select", grid.grid.find("tbody")).filter(".active").length
    if $tr.is(":visible") and not selected
      $tr.fadeOut(->
        $("#thetableclone").height grid.grid.find("thead").height()
      ).attr "hidden"
    else
      $("#thetableclone").height 500 # larger number to be safe
      $tr.fadeIn(->
        $("#thetableclone").height grid.grid.find("thead").height()
      ).removeAttr "hidden"

  toggleSelect: (e) ->
    grid = (if e then e.data.grid else this)
    e.preventDefault()
    e.stopPropagation()
    $(this).button "toggle"
    grid.toggleBulkHandler e

  domainTitleMouseEnter: ->
    $(this).find(".domain-title-cntnr .copy-to-clipboard").css "opacity", 1

  domainTitleMouseLeave: ->
    $(this).find(".domain-title-cntnr .copy-to-clipboard").css "opacity", 0

  windowResize: (e) ->
    grid = (if e then e.data.grid else this)
    spanContainer = grid.grid.find("thead").find(".container").first()
    Scrollbars.update "grid"
    grid.grid.add("#thetableclone").find("thead").find(".container > span").width $("#main-container").width() - (2 * spanContainer.css("padding-left").replace("px", ""))
    grid.grid.find("tbody").find(".container > span").width $("#main-container").width() - (2 * spanContainer.css("padding-left").replace("px", ""))
    grid.positionHorizScroll()
    grid.updateTableHeaders()

  windowScroll: (e) ->
    grid = e.data.grid
    $(".btn-group.open").removeClass "open"
    grid.positionHorizScroll()
    grid.updateTableHeaders()
    if not grid.isWaiting and grid.distanceFromBottom() <= 150
      grid.isWaiting = true
      grid.loadInData()

  bottomOfTable: ->
    $window = $(window)
    $viewport = $(".viewport", @grid)
    ($window.scrollTop() + $window.height()) - ($viewport.offset().top + $viewport.height())

  loadInData: ->
    that = this
    $grid = @grid
    
    # show spinner
    $grid.find("tfoot").removeAttr "hidden"
    $.jsonrpc @options.url,
      offset: @rowOffset
    , (data) ->
      $.jade.getTemplate "grid/row", ->
        records = data.records
        actions = data.actions
        i = 0

        while i < records.length
          
          # push actions onto records
          records[i].actions = actions
          $grid.find("tbody").append $.jade.renderSync("views_grid_row", records[i], that.jadeError)
          ++i
        
        # hide spinner
        $grid.find("tfoot").attr "hidden", true
        
        # let the scroll listener know we're no longer waiting on data
        that.isWaiting = false

      that.rowOffset += 10


  distanceFromBottom: ->
    $(document).height() - ($(window).scrollTop() + $(window).height())

  isTableOnScreen: (offset) ->
    bottomOfScreen = $(window).scrollTop() + $(window).height()
    tableOffset = $(".viewport", @grid).offset().top
    offset = offset or 0
    bottomOfScreen - (tableOffset + offset) >= 0

  positionHorizScroll: ->
    $(".scrollbar", @grid).css "display", (if @isTableOnScreen() then "block" else "none")

  
  # derived from https://bitbucket.org/cmcqueen1975/htmlfloatingtableheader/wiki/Home
  updateTableHeaders: (e) ->
    that = (if e then e.data.grid else this)
    $(".divTableWithFloatingHeader", that.grid).each ->
      theCloneTable = $(".tableFloatingHeader")
      theCloneContainer = theCloneTable.closest("#thetableclone")
      body = $(document.body)
      unless that.options.stickyHeader
        theCloneContainer.css "display", "none"
        body.removeClass "sticky-thead"  if body.hasClass("sticky-thead")
        return
      offset = $(".grid-table", that.grid).offset().top
      scrollTop = $(window).scrollTop()
      viewport = $(that.grid)
      if (scrollTop + $("header#main").height()) - offset > 0 # && (scrollTop - offset - $(this).height() < 0)) {
        theCloneContainer.css "display", "block"
        body.addClass "sticky-thead"  unless body.hasClass("sticky-thead")
      else
        theCloneContainer.css "display", "none"
        body.removeClass "sticky-thead"  if body.hasClass("sticky-thead")
      theCloneTable.css left: -Scrollbars.offset("grid") + "px"
      theCloneContainer.width viewport.width()


$.fn.grid = (option) ->
  @each ->
    $this = $(this)
    data = $this.data("grid")
    $this.data "grid", (data = new Grid(this, option))  unless data
    data[option]()  if typeof option is "string"
