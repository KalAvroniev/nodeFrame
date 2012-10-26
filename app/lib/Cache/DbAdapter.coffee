crypto = require('crypto')
path = require('path')
EventEmitter = require('events').EventEmitter

class DbAdapter
	module.exports = @
			
	constructor: () -> 
		app.options.dbcache.connect()
				
	tagSync: (key, tag) ->
		key = tag + '/' + key
		
	@hashSync: (key) ->
		key = crypto.createHash('md5').update(key).digest('hex')
	
	hashTagSync: (key, tag) ->
		@tagSync(DbAdapter.hashSync(key), tag)
		
	read: (key, expire = 0, cb) ->
		split_key = key.split(path.sep)
		table = if split_key.length > 1 then split_key[0] else 'namespace'
		key = if split_key.length > 1 then split_key[1] else key
		if not app.options.dbcache.isConnected() 
			cb(null, null, true)
		else
			date = new Date()
			expire = Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60
			app.options.dbcache.fetchOne('SELECT val FROM `' + table + '` WHERE id = ? AND (expires = 0 OR expires >= ?)', [key, expire], (err, res) ->		
				if err and (err.code == 'ECONNREFUSED' or err.number == 1049)
					cb(err, res, true)
				else if not res
					cb(true)
				else
					cb(err, res)			
			)
	
	@static_read: (key, expire = 0, cb) ->
		split_key = key.split(path.sep)
		table = if split_key.length > 1 then split_key[0] else 'namespace'
		key = if split_key.length > 1 then split_key[1] else key
		if not app.options.dbcache.isConnected() 
			cb(null, null, true)
		else
			date = new Date()
			expire = Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60
			app.options.dbcache.fetchOne('SELECT val FROM `' + table + '` WHERE id = ? AND (expires = 0 OR expires >= ?)', [key, expire], (err, res) ->
				if err and (err.code == 'ECONNREFUSED' or err.number == 1049)
					cb(err, res, true)
				else if not res
					cb(true)
				else
					cb(err, res)			
			)
	
	write: (key, value, expire = 0, cb) -> 
		split_key = key.split(path.sep)
		table = if split_key.length > 1 then split_key[0] else 'namespace'
		id = if split_key.length > 1 then split_key[1] else key
		if not app.options.dbcache.isConnected() 
			cb(null, null, true)
		else
			if expire != 0
				date = new Date()
				expires = Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60 + expire
			else
				expires = expire
			
			app.options.dbcache.query('REPLACE INTO `' + table + '` VALUES (?, ?, ?)', [id, value, expires], (err, res) =>
				if err 
					if err.code == 'ECONNREFUSED' or err.number == 1049
						cb(err, res, true)
					else
						app.options.dbcache.query('CREATE TABLE IF NOT EXISTS `' + table + '` (id binary(32) NOT NULL, val blob NOT NULL, expires int(11) NOT NULL DEFAULT 0, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8', null, (err) =>
							if not err
								@write(key, value, expire, cb)
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
		
	getNameSpace: (ns, ts = null, cb) ->
		if not ts?
			ns = DbAdapter.hashSync(ns)
			
		DbAdapter.static_read(ns, 0, cb)
		
	setNameSpace: (ns, ts = null, cb, res) ->
		date = new Date()
		if not ts?
			ts = String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)
			ns = DbAdapter.hashSync(ns)
			
		@write(ns, ts, 0, (err, response) ->
			if not err
				cb(ns, ts, res)
			else
				res(err, response)
		)
	
	flushNameSpace: (ns, ts = null, cb) ->
		if ts?
			app.options.dbcache.query('DROP TABLE `' + ts + '`', null, (err)->)
			@flush(ns, cb)
		else
			@read(DbAdapter.hashSync(ns), 0, (err, data) =>
				if not err and data?
					app.options.dbcache.query('DROP TABLE `' + data + '`', null, (err)->)
					@flush(DbAdapter.hashSync(ns), cb)
			)