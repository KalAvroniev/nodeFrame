require('coffee-script')
Application = require('./lib/Application.coffee').Application

// production server
app = new Application({
	'port': 8080,
	'config': 'staging'
});
app.start();

// debug server
debug = new Application({
	'port': 8182,
	'config': 'development'
});
debug.start();
