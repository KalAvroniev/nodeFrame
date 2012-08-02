require.config({
	paths: {
		//jquery: "jquery-1.7.2.min",
		jquery: "jquery-1.8rc1",
		bootstrap: "bootstrap.min",
		socket: "/socket.io/socket.io",
		tinyscrollbar: "jquery.tinyscrollbar-1.8"
	},
	shim: {
		bootstrap: ["jquery"],
		moo: [ "jquery", "jade", "jquery.plugins" ],
		pv3: [ "jquery", "moo" ],
		"tinyscrollbar": ["jquery"],
		"jquery.plugins": ["jquery"],
		"grid": ["jquery"]
	}
});

requirejs([ "jquery", "bootstrap", "socket", "tinyscrollbar", "jade", "jquery.plugins", "moo", "pv3", "grid" ]);