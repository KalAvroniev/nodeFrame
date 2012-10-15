require.config
	baseUrl: '/js'
	
	paths:
		bootstrap: "bootstrap.min"
		socket: "../../node_modules/socket.io/node_modules/socket.io-client/dist/socket.io"
		tinyscrollbar: "jquery.tinyscrollbar"
		
	shim:
    "app-ready": ["app"]
    "app": ["jade-engine", "jsonrpc", "jade"]

require ["bootstrap", "socket", "tinyscrollbar", "jade-engine", "jsonrpc", "jade", "app", "grid", "app-ready"]
