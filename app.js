require('coffee-script')

if(process.env.COVERAGE) {
	Bootstrap = require('./app-cov/Bootstrap.coffee');
} else {
	Bootstrap = require('./app/Bootstrap.coffee');
}

// production server
if(process.env.NODE_ENV === 'production') {
	module.exports.app = app = new Bootstrap({
		'port': 8080,
		'config': 'production'
	});
	app.start();
} else {
	module.exports.app = app = new Bootstrap({
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
