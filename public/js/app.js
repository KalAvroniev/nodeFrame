require.config({
	paths: {
		//jquery: "jquery-1.7.2.min",
		jquery: "jquery-1.8rc1",
		bootstrap: "bootstrap.min",
		socket: "/socket.io/socket.io"
	},
	shim: {
		bootstrap: ["jquery"],
		moo: [ "jquery", "jade", "jquery.plugins" ],
		pv3: [ "jquery", "moo" ],
		"jquery.tinyscrollbar": ["jquery"],
		"jquery.plugins": ["jquery"],
		"grid": ["jquery"]
	}
});

requirejs([ "jquery", "bootstrap", "jquery.tinyscrollbar", "jade", "moo", "jquery.plugins", "pv3", "socket", "grid" ]);