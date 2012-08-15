require.config
  baseUrl: "/js"
	
  paths:    
    #jquery: "jquery-1.7.2.min",
    jquery: "jquery-1.8rc1"
    bootstrap: "bootstrap.min"
    
  shim:
    bootstrap: ["jquery"]

requirejs ["jquery", "bootstrap"]