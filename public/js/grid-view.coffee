(->
  onDomLoad = ->
    ++domLoaded
    return  if domLoaded > 1
    loadDataIntoTable()
    
    # setup all the events
    $(document.body).not(".mobile").find(".domain-title").on
      mouseenter: domainTitleMouseEnter
      mouseleave: domainTitleMouseLeave

    $("#main-container").on "click", ".grid-table .sticky", toggleSticky
    $(".grid-table").children("tbody").on("click", ".domain-title-cntnr .copy-to-clipboard", preventEvent).on("click", "td button.favourite", toggleFavourite).on("click", "td button.select", toggleSelect).on "click", "td:not(#zero-alert)", ->
      $this = $(this)
      $row = $this.closest("tr")
      parent = undefined
      rowIsSelected = undefined
      if $row.hasClass("child")
        
        # clicking on the child row
        $row.fadeOut ->
          $this.prev().removeClass("row-sel parent-open").remove()
          return		
        return						
      else
        $parent = $row.parent()
        rowIsSelected = $row.hasClass("parent-open")
        
        # fade out / remove all "open" child rows
        $parent.children("tr.row-sel.child").fadeOut ->
          $this.prev().removeClass("row-sel parent-open").remove()
          return
        unless rowIsSelected
          $row.addClass "row-sel parent-open"
          $row.after "<tr class=\"row-sel child\" style=\"display:none;\"><td colspan=\"" + row.find("td").length + "\"><div class=\"child-inner\"> <a class=\"x-row-sel\" href=\"javascript:void(0);\">x</a><p><strong>selected domain content</strong> <br>to be placed in here …</p></div></td></tr>"
          $row.next().fadeIn()
          return					

    $(window).on("resize", windowResize).on "scroll", windowScroll
    $(verticalScroll + ", " + horizontalScroll).on "resize", copyHeaderSize
    $(horizontalScroll).on "tsb_scroll", horizontalScroll + " > .scrollbar", UpdateTableHeaders
    
    # other... stuff
    $(tableHead).each ->
      $this = $(this)
      $parent = $this.parent()
      originalHeaderRow = undefined
      cloneTable = undefined
      clonedHeaderRow = undefined
      if $parent.css("position") is "relative"
        $parent.addClass "divTableWithFloatingHeader"
      else
        $this.wrap "<div class=\"divTableWithFloatingHeader\" style=\"position: relative;\" />"
      originalHeaderRow = $("thead:first", this)
      cloneTable = $("#thetableclone").children("table")
      clonedHeaderRow = cloneTable.append(originalHeaderRow.clone())
      clonedHeaderRow.closest("#thetableclone").css
        top: $("header#main").height()
        left: $this.css("margin-left") + $this.offset().left

      clonedHeaderRow.addClass "tableFloatingHeader"
      originalHeaderRow.addClass "tableFloatingHeaderOriginal"
      copyHeaderSize()
      return			

    $(horizontalScroll).tinyscrollbar
      axis: "x"
      scroll: false

    innerOuterOffset = getInnerOuterOffset()
    tableHeaderOffset = getTableHeaderOffset()
    positionHorizScroll()
    UpdateTableHeaders()
    return
		
  onDomUnload = ->
    $("div.divTableWithFloatingHeader").remove()
    $(document.body).not(".mobile").find("td.domain-title").off
      mouseenter: domainTitleMouseEnter
      mouseleave: domainTitleMouseLeave

    $("#main-container").off "click", ".grid-table th.sticky", toggleSticky
    $(".grid-table").children("tbody").off("click", ".domain-title-cntnr .copy-to-clipboard", preventEvent).off("click", "td button.favourite", toggleFavourite).off "click", "td button.select", toggleSelect
    $(window).off("resize", windowResize).off "scroll", windowScroll
    $(verticalScroll + ", " + horizontalScroll).off "resize", copyHeaderSize
    $(horizontalScroll).off "tsb_scroll", horizontalScroll + " > .scrollbar", UpdateTableHeaders
    exchangeDomainResults = null  if typeof exchangeDomainResults isnt "undefined"
    return		
  
  # note that we don't bother deleting the tinyscrollbar, as it will be
  # removed when the DOM elements are.
  preventEvent = (e) ->
    e.preventDefault()
    false
		
  toggleSticky = (e) ->
    spans = $(".grid-table th.sticky").children("span")
    if stickyHeaderEnabled
      stickyHeaderEnabled = false
      spans.removeClass("on").addClass "off"
      $(document.body).removeClass "sticky-thead"
    else
      stickyHeaderEnabled = true
      spans.addClass("on").removeClass "off"
    UpdateTableHeaders()
    preventEvent e
		
  toggleFavourite = (e) ->
    $(this).button "toggle"
    preventEvent e
		
  toggleSelect = (e) ->
    $(this).button "toggle"
    preventEvent e		
		
  domainTitleMouseEnter = ->
    $(this).find(".domain-title-cntnr .copy-to-clipboard").css "opacity", 1
    return
		
  domainTitleMouseLeave = ->
    $(this).find(".domain-title-cntnr .copy-to-clipboard").css "opacity", 0
    return
		
  windowResize = ->
    $(horizontalScroll).tinyscrollbar_update "relative"
    innerOuterOffset = getInnerOuterOffset()
    tableHeaderOffset = getTableHeaderOffset()
    positionHorizScroll()
    UpdateTableHeaders()
    return		
		
  windowScroll = ->
    $(".btn-group.open").removeClass "open"
    innerOuterOffset = getInnerOuterOffset()
    tableHeaderOffset = getTableHeaderOffset()
    positionHorizScroll()
    UpdateTableHeaders()
    return
		
  getInnerOuterOffset = ->
    scrollOffset = $(verticalScroll).scrollTop()
    vertOffset = $(verticalScroll).offset().top
    innerOffset = $(horizontalScroll).offset().top
    (innerOffset - scrollOffset) - vertOffset
		
  getTableHeaderOffset = ->
    scrollOffset = $(verticalScroll).scrollTop()
    vertOffset = $(verticalScroll).offset().top
    tableOffset = $(horizontalScroll + " table").offset().top
    $("#grid-view .grid-table").offset().top
		
  isTableOnScreen = (offset) ->
    bottomOfScreen = $(window).scrollTop() + $(window).height()
    tableOffset = $(horizontalScroll + " table").offset().top
    offset = offset or 0
    bottomOfScreen - (tableOffset + offset) >= 0
		
  positionHorizScroll = ->
    viewHeight = $(verticalScroll).height()
    scrollOffset = $(verticalScroll).scrollTop()
    scroll = $(horizontalScroll + " > .scrollbar")
    scroll.css "display", (if isTableOnScreen() then "block" else "none")
    return		
  
  # derived from https://bitbucket.org/cmcqueen1975/htmlfloatingtableheader/wiki/Home
  UpdateTableHeaders = ->
    $("div.divTableWithFloatingHeader").each ->
      theClone = $(".tableFloatingHeader")
      theCloneTable = theClone.closest("table")
      theCloneContainer = theClone.closest("#thetableclone")
      body = $(document.body)
      unless stickyHeaderEnabled
        theCloneContainer.css "display", "none"
        body.removeClass "sticky-thead"  if body.hasClass("sticky-thead")
        return
      offset = tableHeaderOffset
      scrollTop = $(window).scrollTop()
      viewport = $(this).closest(".viewport")
      if (scrollTop + $("header#main").height()) - offset > 0 # && (scrollTop - offset - $(this).height() < 0)) {
        theCloneContainer.css "display", "block"
        body.addClass "sticky-thead"  unless body.hasClass("sticky-thead")
      else
        theCloneContainer.css "display", "none"
        body.removeClass "sticky-thead"  if body.hasClass("sticky-thead")
      theCloneTable.css left: -$(horizontalScroll).tinyscrollbar_offset() + "px"
      theCloneContainer.width viewport.width()
      return
    return			

  copyHeaderSize = ->
    $("div.divTableWithFloatingHeader").each ->
      originalHeaderRow = $(".tableFloatingHeaderOriginal", this)
      clonedHeaderRow = $(".tableFloatingHeader", this)
      
      # copy cell widths from original header
      $("th", clonedHeaderRow).each (i) ->
        $(this).css "width", $("th", originalHeaderRow).eq(i).css("width")
        return
      return
    return			


  
  # this function relies on a variable exchangeDomainResults as defined
  # in the global scope
  loadDataIntoTable = ->
    tableData = undefined
    table = undefined
    return  if typeof exchangeDomainResults is "undefined" or exchangeDomainResults is null
    tableData = $.parseJSON(exchangeDomainResults)
    table = $(".grid-table tbody")
    
    # clean up the table
    table.find("tr").remove()
    if not tableData or tableData.error
      console.log "Error retreiving domain data: " + tableData.error  if tableData
      table.append "<tr><td id=\"zero-alert\" colspan=\"17\"><span class=\"ff-icon-before\"><a class=\"ff-icon x-zero-alert\" href=\"javascript:void(0);\"></a><strong>Sorry</strong>, there was an error retreiving domain listings. Please try again.</td></tr>"
      return
    if tableData.length is 0
      table.append "<tr><td id=\"zero-alert\" colspan=\"17\"><span class=\"ff-icon-before\"><a class=\"ff-icon x-zero-alert\" href=\"javascript:void(0);\"></a><strong>Sorry</strong>, we couldn't find any exact matches for this keyword.</td></tr>"
    else
      i = 0

      while i < tableData.length
        domain = tableData[i]
        table.append "<tr> \t\t\t\t\t<td><button class=\"btn select\" data-toggle=\"button\"></button></td> \t\t\t\t\t<td><button class=\"btn favourite\" data-toggle=\"button\"></button></td> \t\t\t\t\t<td class=\"actions\"><span class=\"action-buttons\"><a href=\"#\" title=\"Build website\"></a><a href=\"#\" title=\"List for sale\"></a></span></td> \t\t\t\t\t<td class=\"domain-title\"><span class=\"domain-title-cntnr\">" + domain.domain.nameonly + " <span class=\"tld\">" + domain.domain.tld + "</span></span></td> \t\t\t\t\t<td class=\"date\">" + domain.auction_details[0].auction_end_date + "</td> \t\t\t\t\t<td class=\"currency\">" + domain.auction_details[0].auction_price + "</td> \t\t\t\t\t<td>" + domain.auction_details[0].auction_bidders + "</td> \t\t\t\t\t<td>" + domain.domain.chars + "</td> \t\t\t\t\t<td>" + ((if domain.domain.dash then "?" else "-")) + "</td> \t\t\t\t\t<td>" + domain.domain.tld + "</td> \t\t\t\t\t<td>" + ((if domain.tld_available.com isnt "0" then "?" else "?")) + "</td> \t\t\t\t\t<td>" + ((if domain.tld_available.net isnt "0" then "?" else "?")) + "</td> \t\t\t\t\t<td>" + ((if domain.tld_available.org isnt "0" then "?" else "?")) + "</td> \t\t\t\t\t<td>" + domain.pagerank.pagerank + "</td> \t\t\t\t\t<td>" + domain.backlinks.edu + "</td> \t\t\t\t\t<td>" + domain.backlinks.gov + "</td> \t\t\t\t\t<td>" + domain.backlinks.google + "</td> \t\t\t\t</tr>"
        ++i
    return				
				
  horizontalScroll = "#grid-view"
  tableHead = "table.floatable"
  innerOuterOffset = undefined
  tableHeaderOffset = undefined
  domLoaded = 0
  stickyHeaderEnabled = true
  onDomLoad()
  $(document).on "click", "#toggle-side-bar, #x-side-bar", (e) ->
    windowResize()
    windowScroll()
    return		
  return
)()