crypto = require('crypto')
path = require('path')
EventEmitter = require('events').EventEmitter

class DbAdapter
	module.exports = @
			
	constructor: () -> 
		app.options.dbcache.connect()
				
	tag: (key, tag) ->
		key = tag + '/' + key
		
	@hash: (key) ->
		key = crypto.createHash('md5').update(key).digest('hex')
	
	hashTag: (key, tag) ->
		@tag(DbAdapter.hash(key), tag)
		
	read: (key, cb) ->
		split_key = key.split(path.sep)
		table = if split_key.length > 1 then split_key[0] else 'namespace'
		key = if split_key.length > 1 then split_key[1] else key
		if not app.options.dbcache.isConnected() 
			cb(null, null, true)
		else
			app.options.dbcache.fetchOne('SELECT val FROM `' + table + '` WHERE id = ?', [key], (err, res) ->		
				if err and (err.code == 'ECONNREFUSED' or err.number == 1049)
					cb(err, res, true)
				else if not res
					cb(true)
				else
					cb(err, res)			
			)
	
	@static_read: (key, cb) ->
		split_key = key.split(path.sep)
		table = if split_key.length > 1 then split_key[0] else 'namespace'
		key = if split_key.length > 1 then split_key[1] else key
		if not app.options.dbcache.isConnected() 
			cb(null, null, true)
		else
			app.options.dbcache.fetchOne('SELECT val FROM `' + table + '` WHERE id = ?', [key], (err, res) ->
				if err and (err.code == 'ECONNREFUSED' or err.number == 1049)
					cb(err, res, true)
				else if not res
					cb(true)
				else
					cb(err, res)			
			)
	
	write: (key, value, cb) -> 
		split_key = key.split(path.sep)
		table = if split_key.length > 1 then split_key[0] else 'namespace'
		id = if split_key.length > 1 then split_key[1] else key
		if not app.options.dbcache.isConnected() 
			cb(null, null, true)
		else
			app.options.dbcache.query('REPLACE INTO `' + table + '` VALUES (?, ?)', [id, value], (err, res) =>
				if err 
					if err.code == 'ECONNREFUSED' or err.number == 1049
						cb(err, res, true)
					else
						app.options.dbcache.query('CREATE TABLE IF NOT EXISTS `' + table + '` (id binary(32) NOT NULL, val blob NOT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8', null, (err) =>
							if not err
								@write(key, value, cb)
						)
				else if not res
					cb(true)
				else
					cb(err, res)			
			)
		
	flush: (key, cb) ->
		split_key = key.split(path.sep)
		table = if split_key.length > 1 then split_key[0] else 'namespace'
		key = if split_key.length > 1 then split_key[1] else key
		if not app.options.dbcache.isConnected() 
			cb(null, null, true)
		else
			app.options.dbcache.query('DELETE FROM `' + table + '` WHERE id = ?', [key], (err, res) ->
				if err and (err.code == 'ECONNREFUSED' or err.number == 1049)
					cb(err, res, true)
				else if not res
					cb(true)
				else
					cb(err, res)			
			)
		
	getNameSpace: (ns, cb) ->
		DbAdapter.static_read(DbAdapter.hash(ns), cb)
		
	setNameSpace: (ns, cb, res) ->
		date = new Date()
		ts = String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)
		@write(DbAdapter.hash(ns), ts, (err, response) ->
			if not err
				cb(ns, res)
			else
				res(err, response)
		)
	
	flushNameSpace: (ns, cb) ->
		@read(DbAdapter.hash(ns), (err, data) =>
			if not err and data?
				app.options.dbcache.query('DROP TABLE `' + data + '`', null, (err)->)
				@flush(DbAdapter.hash(ns), cb)
		)