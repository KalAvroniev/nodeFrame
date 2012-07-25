require('coffee-script')
Application = require('./lib/Application.coffee').Application

// production server
app = new Application({
	'port': 8181
});
app.start();

// debug server
debug = new Application({
	'port': 8182,
	'debug': true
});
debug.start();
