require('coffee-script')
Bootstrap = require('./Bootstrap.coffee')

// production server
app = new Bootstrap({
	'port': 8080,
	'config': 'staging'
});
app.start();

// debug server
debug = new Bootstrap({
	'port': 8182,
	'config': 'development'
});
debug.start()
