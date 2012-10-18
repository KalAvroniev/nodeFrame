winston = require('winston')
Email = require('./Loggers/Email')
SMS = require('./Loggers/SMS')
	
config =
	levels:
		debug: 0
		info:  1
		warn:  2
		error: 3
		fatal: 4
	colors:
		debug: 'cyan'
		info:  'green'
		warn:  'grey'
		error: 'yellow'
		fatal: 'red'
	
winston.loggers.add('debug',
	transports: [
		new winston.transports.Console(
			level:     'debug'
			colorize:  true
			timestamp: true
			#handleExceptions: true
		)
	]
)

winston.loggers.add('warn',
	transports: [
		new winston.transports.File(
			level:     'warn'
			timestamp: true
			filename:  '/var/log/nodejs/error.log'
			maxsize:   104857600
			maxFiles:  7
		)
	]
)

winston.loggers.add('error',
	transports: [
		new winston.transports.File(
			level:     'error'
			timestamp: true
			filename:  '/var/log/nodejs/error.log'
			maxsize:   104857600
			maxFiles:  7
			#handleExceptions: true
		),
		new Email(
			level:     'error'
		)
	]
)
		
winston.loggers.add('fatal',
	transports: [
		new winston.transports.File(
			level:     'fatal'
			timestamp: true
			filename: '/var/log/nodejs/error.log'
			maxsize: 104857600
			maxFiles: 7
		),
		new Email(
			level:     'fatal'
		),
		new SMS(
			level:     'fatal'
		)
	]
)

winston.addColors(config.colors)

module.exports.errorHandler = (err, req, res, next) ->
	console.log(err)
	res.end()

module.exports.appLoggerSync = (err, type = 'debug') ->
	if not (err instanceof Error)
		err = new Error(err)
		log = err.message
	else
		log = err.stack
	
	# set or overwrite err.type based on if it exists and if overwrite level higher than current
	err.type = if (err.type? and (if config.levels[err.type]? then config.levels[err.type] else config.levels['warn']) >= config.levels[type]) then err.type else type
	if process.env.NODE_ENV == 'production'
		logger = winston.loggers.get(err.type)
	else
		logger = winston.loggers.get('debug')

	logger.setLevels(config.levels)
	switch err.type
		when 'debug'
			if process.env.NODE_ENV != 'production'
				logger.debug(log)
		when 'error'
			logger.error(log)
		when 'fatal'
			logger.fatal(log)
		else
			logger.warn(log)
	
	return err
	
class appError extends Error	
	module.exports.appError = @

	constructor: (msg, caller, type, code = null) ->
		Error.call(@)
		Error.captureStackTrace(@, @constructor)
		@name = caller.constructor.name + 'Error'
		@message = msg
		@type = type
		@code = code
		