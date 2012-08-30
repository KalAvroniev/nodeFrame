require('coffee-script')
Bootstrap = require('./Bootstrap.coffee')

// production server

if(process.env.NODE_ENV === 'production') {
	app = new Bootstrap({
		'port': 8080,
		'config': 'production'
	});
	app.start();
} else {
	app = new Bootstrap({
		'port': 8181,
		'config': 'staging'
	});
	app.start();
/*
	// debug server
	debug = new Bootstrap({
		'port': 8182,
		'config': 'development'
	});
	debug.start()
*/
}
