require.config
  baseUrl: "/js"
  waitSeconds: 30
	
  paths:    
    #jquery: "jquery-1.7.2.min",
    #jquery: "jquery-1.8rc1"
    bootstrap: "bootstrap.min"
    socket: "/socket.io/lib/socket.io"
    
    #tinyscrollbar: "jquery.tinyscrollbar-1.8"
    tinyscrollbar: "jquery.tinyscrollbar"

  shim:
    "app-ready": ["app"]
    "app": ["jade-engine", "jsonrpc", "jade"]
    #bootstrap: ["jquery"]
    #tinyscrollbar: ["jquery"]
    #grid: ["jquery"]
		

requirejs ["bootstrap", "socket", "tinyscrollbar", "jade-engine", "jsonrpc", "jade", "app", "grid", "app-ready"]