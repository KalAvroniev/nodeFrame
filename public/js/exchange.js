// Generated by CoffeeScript 1.3.3

(function() {
  var domLoaded, onDomLoad, onDomUnload, windowResize, windowScroll;
  onDomLoad = function() {
    domLoaded++;
    $("#portfolio-data-tabs a").click(function(e) {
      e.preventDefault();
      $(this).tab("show");
    });
    $("#temp-make-offer").on("click", function(e) {
      e.preventDefault();
      console.log("temp make offer");
      Panels.add({
        id: "temp-make-offer",
        url: "/modules/exchange/panels/make-offer",
        temporary: true,
        h1: "temp-make-offer",
        h2: "moo in here"
      }, true);
    });
    $("#temp-place-bid").on("click", function(e) {
      e.preventDefault();
      console.log("temp place bid");
      Panels.add({
        id: "temp-place-bid",
        url: "/modules/exchange/panels/place-bid",
        temporary: true,
        h1: "temp-place-bid",
        h2: "moo in here"
      }, true);
    });
    $("#temp-backorder").on("click", function(e) {
      e.preventDefault();
      console.log("temp backorder");
      Panels.add({
        id: "temp-backorder",
        url: "/modules/exchange/panels/backorder",
        temporary: true,
        h1: "temp-backorder",
        h2: "moo in here"
      }, true);
    });
    $("#temp-watchlist").on("click", function(e) {
      e.preventDefault();
      console.log("temp watchlist");
      Panels.add({
        id: "temp-watchlist",
        url: "/modules/exchange/panels/watchlist",
        temporary: true,
        h1: "temp-watchlist",
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
    $("#temp-domain-details").on("click", function(e) {
      e.preventDefault();
      console.log("temp domain details");
      Panels.add({
        id: "temp-domain-details",
        url: "/panels/domain-details",
        temporary: true,
        h1: "temp-domain-details",
        h2: "moo in here"
      }, true);
    });
    $(".sectional-tabs li").addClass("hidden");
    $(".sectional-tabs li#watchlist").removeClass("hidden");
    $(".sectional-tabs").addClass("singular");
    $(window).on("resize", windowResize);
    $(window).on("scroll", windowScroll);
  };
  onDomUnload = function() {
    $(".ajax-spinner").show();
    $(window).off("resize", windowResize);
    $(window).off("scroll", windowScroll);
  };
  windowResize = function() {};
  windowScroll = function() {};
  domLoaded = 0;
  $("#main-container").one({
    ajaxUnload: onDomUnload
  });
})();

$(document).ready(function() {
  $("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr("data-alerts", $(".protrada .alert-count").attr("data-alerts"));
});
