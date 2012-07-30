require.config({
	paths: {
		jquery: "jquery-1.7.2.min",
		bootstrap: "bootstrap.min",
		socket: "/socket.io/socket.io"
	},
	shim: {
		bootstrap: ["jquery"],
		moo: [ "jquery", "jade" ],
		pv3: [ "jquery", "moo" ],
		"jquery.tinyscrollbar": ["jquery"],
		"jquery.plugins": ["jquery"]
	}
});

requirejs([ "jquery", "bootstrap", "jquery.tinyscrollbar", "jade", "moo", "jquery.plugins", "pv3", "socket" ]);