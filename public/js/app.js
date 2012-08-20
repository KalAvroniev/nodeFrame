// Generated by CoffeeScript 1.3.3
var Alert, HelpBubbles, NotificationsController, Panels, Scrollbars, TaskStatus, protrada, togglePanel, toggleSidebar, verticalScroll;

$.app = {};

$.app.growl = {};

$.app.growl.hide = function() {
  $(".task-status").removeClass("active").css("display", "none");
};

/*
@param type "success" or "error"
@param message HTML message (can be raw text)
*/


$.app.growl.show = function(type, message) {
  $.app.growl.hide();
  $(".task-status." + type).css("display", "block").addClass("active");
  $(".status-content h2").html(type).next().html(message);
};

$.app.state = {};

$.app.state.get = function(success, options) {
  $.jsonrpc("user/get-state", {}, (function(data) {
    if (data !== undefined) {
      $.app.state.current = data;
      if (success) {
        success();
      }
      $(document).ready(function() {
        $(this).trigger("restore");
      });
    }
  }), (function(error) {
    console.error(error);
  }), options);
};

$.app.state.restoreModule = function() {
  var module;
  module = (!$.app.state.current.modules.selected || $.app.state.current.modules.selected === "" ? "home" : $.app.state.current.modules.selected);
  module = module.replace("#", "");
  window.history.pushState("", module, "/" + module);
  $("#main-container").trigger("ajaxUnload");
  $.app.state.update("modules.selected", module);
  $.ajax("/modules/" + module + "?ajax=1", {
    success: function(data) {
      var modules;
      $("#ajax-container").html(data);
      $(".selected").removeClass("selected");
      $("#spine-inner nav li a#nav-" + module).parent().addClass("selected");
      $(".ajax-spinner").hide();
      modules = $.app.state.current.modules;
      if (modules[modules.selected] !== undefined && modules[modules.selected].panel !== undefined && (modules[modules.selected].panel.active != null)) {
        $.app.panel.show(modules[modules.selected].panel.active.url, modules[modules.selected].panel.active.options);
      }
    }
  });
};

$.app.state.restore = function() {
  $(document).ready(function() {
    if ($.app.state.current === undefined) {
      $.app.state.get(function() {
        if ($.app.state.current.modules !== undefined && $.app.state.current.modules.selected !== undefined) {
          $.app.state.restoreModule($.app.state.current.modules);
        }
      });
    }
  });
};

$.app.state.update = function(stateName, stateValue) {
  $.jsonrpc("user/update-state", {
    name: stateName,
    value: stateValue
  }, (function(result) {
    $.app.state.current = result;
  }), function(error) {
    console.error(error);
  });
};

$.fn.reorderActiveElement = function() {
  return this.children(".active").detach().prependTo(this);
};

$.fn.restoreStandoutElement = function() {
  return this.children(".standout-tab").detach().prependTo(this);
};

toggleSidebar = function(e) {
  var $aside;
  $aside = $("aside");
  $aside.toggleClass("active");
  $(document.body).toggleClass("sidebar-hidden sidebar-open");
  $("#main-container, .task-status").delay(($(document.body).hasClass("sidebar-hidden") ? 200 : 0)).animate({
    width: ($aside.hasClass("active") ? "99.999" : "100") + "%"
  }, 200, function() {
    Scrollbars.updateAll();
    $("#grid-view").grid("windowResize");
  });
};

protrada = {
  version: "3a2",
  cachedAt: 1343982244107,
  scrollbars: {
    elements: {},
    add: function(identifier, $element, options) {
      this.elements[identifier] = $element.tinyscrollbar(options || {});
    },
    update: function(identifier, type) {
      this.elements[identifier].tinyscrollbar_update(type || "relative");
    },
    updateAll: function(type) {
      var that;
      that = this;
      $.each(this.elements, function(i, v) {
        that.update(i, type);
      });
    },
    offset: function(identifier) {
      return this.elements[identifier].tinyscrollbar_offset();
    },
    remove: function(identifier) {
      this.elements[identifier].children(".scrollbar").remove();
    }
  },
  alert: {
    show: function(message) {
      $("#sys-alert").removeClass("hidden").find(".alertmsg-container").find("span").text(message);
    },
    hide: function() {
      $("#sys-alert").addClass("hidden");
    }
  },
  taskStatus: {
    show: function(type, message) {
      $.app.growl.show(type, message);
    },
    hide: function() {
      $.app.growl.hide();
    }
  },
  helpBubbles: {
    bubbles: {}
  },
  panels: {
    store: {},
    curPanelID: null,
    prevPanelID: null,
    defaultPanel: null,
    defaults: {
      "default": false,
      temporary: false,
      extraClasses: null
    },
    init: function() {
      $(document).on("click", ".panel-tab", function(e) {
        e.preventDefault();
        Panels.show($(this).data());
      });
      $(document).on("click", ".x-panel", function(e) {
        e.preventDefault();
        Panels.hide();
      });
    },
    add: function(options, showImmediately) {
      var tabContainer, tabHTML;
      if (showImmediately == null) {
        showImmediately = false;
      }
      options = $.extend({}, this.defaults, options);
      if (options.id === void 0 || options.url === void 0 || options.size === void 0) {
        return;
      }
      if ($("#" + options.id).length) {
        return;
      }
      if (options.temporary) {
        options["default"] = false;
      }
      tabContainer = $("#main").find(".sectional-tabs");
      tabHTML = '<li id="' + options.id + '" class="' + (options["default"] || showImmediately ? "standout-tab" : "") + (options.temporary ? " temporary-tab" : "") + '"><a href="#" data-id="' + options.id + '" data-url="' + options.url + '" data-size="' + options.size + '"' + (options.temporary ? ' data-temporary="true"' : "") + (options.extraClasses ? ' data-extra-classes="' + options.extraClasses + '"' : "") + ' class="panel-tab"><strong>' + options.h1 + '</strong>' + options.h2 + '</a></li>';
      tabContainer.prepend(tabHTML);
      if (options["default"]) {
        this.defaultPanel = $("#" + options.id);
      }
      if (showImmediately) {
        this.show(options);
      } else {
        this.shuffle();
      }
    },
    remove: function(id, empty) {
      var tabToClose;
      if (empty == null) {
        empty = false;
      }
      tabToClose = $("#main").find(".sectional-tabs").find("#" + id);
      if (tabToClose.hasClass("active")) {
        empty = true;
        this.hide();
      }
      /* do we need this? 
      if (empty) {
        $("#p").remove();
      }*/ 
      tabToClose.remove();
    },
    show: function(data) {
      this.hide();
      if (this.prevPanelID === data.id) {
        return;
      }
      $.ajax(data.url, {
        success: function(html) {
          $("#section-panel").addClass("hidden");
          $("#ajax-container").prepend(html);
          $("#main").find(".sectional-tabs").find("#" + data.id).addClass("active");
          Panels.defaultPanel = $("#main").find(".sectional-tabs");
          Panels.curPanelID = data.id;
          Panels.shuffle();
        }        
      });          
    },
    shuffle: function() {
      var tabContainer;
      tabContainer = $("#main").find(".sectional-tabs");
      tabContainer.find(".active").detach().prependTo(tabContainer);
    },
    hide: function() {

      var temporaryTab;
      temporaryTab = $("#main").find(".sectional-tabs").find(".temporary-tab");
      
      $("#main").find(".sectional-tabs").find(".active").removeClass("active");
      
      $("#section-panel").addClass("hidden");
      
      $("#section-panel").delay(300).queue(function() {
      	
		    $("#section-panel.hidden").remove();
		    
	  });
    
      if (this.defaultPanel) {
        this.defaultPanel.addClass("standout-tab");
      }
      this.prevPanelID = this.curPanelID;
      this.curPanelID = null;
      if (temporaryTab.length && this.prevPanelID === temporaryTab.attr("id")) {
        this.remove(this.prevPanelID, true);
      }
      
    }
  }
};

Scrollbars = protrada.scrollbars;

TaskStatus = protrada.taskStatus;

Alert = protrada.alert;

HelpBubbles = protrada.helpBubbles;

Panels = protrada.panels;

$(document).on("click", "#toggle-side-bar, #x-side-bar", function() {
  toggleSidebar();
  $.app.state.update("sidebar.visible", !$(document.body).hasClass("sidebar-hidden"));
});

$(document).on("click", ".x-alert-msg", function() {
  $(this).parent().slideUp(450, function() {
    $(this).remove();
    Scrollbars.update("notifications");
  });
});

$(document).on("click", ".nav-tabs li a", function(e) {
  e.preventDefault();
  $(this).tab("show");
});

$(document).on("click", "#alert-msgs a", function(e) {
  e.preventDefault();
  $(this).tab("show");
  Scrollbars.update("notifications");
});

$(document).on("restore", function() {
  var sidebar, state;
  state = $.app.state.current.system_options;
  sidebar = $.app.state.current.sidebar;
  if (state !== undefined) {
    $.each(state.toggles, function(k, v) {
      var id;
      id = "#ui-controls #" + k;
      if ((v && !$(id).hasClass("active")) || (!v && $(id).hasClass("active"))) {
        $(id).click();
      }
    });
    $("#system-rocker").find("h3").addClass("hidden").filter("#" + state.mode).removeClass("hidden");
    $("#mode-rocker").removeClass("active").addClass(function() {
      if (state.mode === "devname") {
        return "active";
      } else {
        return "";
      }
    });
  }
  if ((sidebar !== undefined ? sidebar.visible !== undefined : void 0) ? (sidebar.visible && $(document.body).hasClass("sidebar-hidden")) || (!sidebar.visible && !$(document.body).hasClass("sidebar-hidden")) : void 0) {
    toggleSidebar();
  }
});

togglePanel = function(selectorName, contentCallback) {
  var $panel, $this;
  $this = $(this);
  $panel = $("#section-panel");
  if ($panel.data("tab") === selectorName) {
    $panel.addClass("hidden").removeData("tab");
  } else {
    if ($panel.hasClass("hidden")) {
      $panel.removeClass("hidden");
    } else {
      $this.siblings().removeClass("active");
    }
    $panel.html(contentCallback()).data("tab", selectorName);
  }
  if ($panel.hasClass("hidden")) {
    $this.removeClass("active");
  } else {
    $this.addClass("active");
  }
};

NotificationsController = function(notifications) {
  this.notifications = notifications;
};

verticalScroll = "body";

Number.prototype.toMoney = function(decimals, decimal_sep, thousands_sep) {
  var c, d, i, j, n, sign, t;
  n = this;
  c = (isNaN(decimals) ? 2 : Math.abs(decimals));
  d = decimal_sep || ".";
  t = (typeof thousands_sep === "undefined" ? "," : thousands_sep);
  sign = (n < 0 ? "-" : "");
  i = parseInt(n = Math.abs(n).toFixed(c)) + "";
  j = ((j = i.length) > 3 ? j % 3 : 0);
  return sign + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
};

NotificationsController.prototype.render = function() {
  var ns;
  ns = this.notifications;
  $.jade.getTemplate("notifications/generic", (function(fn) {
    var i, notif;
    $("#protrada-msgs.no-alerts").removeClass("no-alerts").find(".alerts-listing").html(" ");
    i = 0;
    while (i < ns.length) {
      notif = $.jade.renderSync(fn, ns[i]);
      $("#protrada-msgs").append(notif);
      ++i;
    }
    $("header#main").find(".alerts-summary").find("span[data-title^=\"Protrada\"]").attr("data-alerts", ns.length);
    $(".protrada .alert-count").attr("data-alerts", ns.length);
    Scrollbars.update("notifications");
  }), function(error) {
    alert(error);
  });
};

/*
$(document).ready ->
  module = document.URL.substr(document.URL.lastIndexOf("/") + 1) or "home"
  if module isnt ""
    $.app.state.update "modules.selected", module
    $.app.state.get ->
      $.app.state.restoreModule()
      return

  $("#ui-controls").on "click", "a", (e) ->
    classes =
      condensed: "condensed"
      downgrade: "mobile"
      helpbubbles: "help"

    e.preventDefault()
    $(document.body).toggleClass classes[@id.replace(/toggle|-/g, "")]
    $(this).toggleClass "active"
    $.app.state.update "system_options.toggles." + @id, $(this).hasClass("active")
    return

  $("#toggle-condensed").toggleClass "active", $(document.body).hasClass("condensed")
  $("#toggle-downgrade").toggleClass "active", $(document.body).hasClass("mobile")
  $("#toggle-sys-menu").on "click", (e) ->
    e.preventDefault()
    $(this).add("#sys-menu").toggleClass "active"
    return

  $("#x-sys-menu").on "click", (e) ->
    e.preventDefault()
    $("#sys-menu, #toggle-sys-menu").removeClass "active"
    return
		
  $("#mode-rocker").on "click", (e) ->
    e.preventDefault()
    $("#system-rocker").find("h3").toggleClass "hidden"
    $(this).toggleClass "active"
    $.app.state.update "system_options.mode", $("#system-rocker").find("h3").not(".hidden").attr("id")
    return
		
  $("#notifications").addClass "native"  if $(document.body).hasClass("mobile")
  Scrollbars.add "notifications", $("#notifications").not(".native"),
    lockscroll: false
		
  $("#spine-inner").find("nav").find("a").mouseup(->
    $(this).removeClass "active"
    return
  ).mousedown(->
    $(this).addClass "active"
    return		
  ).mouseout ->
    $(this).removeClass "active"
    return		

  $(document).on "click", ".hide-all-bubbles", (e) ->
    e.preventDefault()
    $("#toggle-help-bubbles").trigger "click"
    return

  $(document).on "click", ".x-help-bubble", (e) ->
    e.preventDefault()
    $(this).closest(".help-bubble-container").hide()
    return
	
  $(".dropdown-toggle").dropdown()
  $(window).resize ->
    Scrollbars.update "notifications"
    return

  $("#system-help, #live-help-status, #live-help-info > a").on "click", (e) ->
    e.preventDefault()
    TaskStatus.show "error", "The Live Help system is coming soon."
    return

  document.socketio = io.connect("http://" + location.host)
  document.socketio.on "logout", ->
    document.location = "/login"
    return		

  $.jsonrpc "notifications/fetch", {}, (data) ->
    notif = new NotificationsController(data.notifications)
    notif.render()
    document.socketio.on "notification", (msg) ->
      notif.notifications.unshift msg.data
      notif.render()
      return		
    return
  return
*/
