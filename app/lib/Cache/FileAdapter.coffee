fs = require('fs')
crypto = require('crypto')
path = require('path')

class FileAdapter
	module.exports = @
	
	constructor: () ->
				
	tag: (file, folder) ->
		file = folder + '/' + file
		
	@hash: (file) ->
		file = crypto.createHash('md5').update(file).digest('hex')
	
	hashTag: (file, folder) ->
		@tag(FileAdapter.hash(file), folder)
	
	read: (file, cb, expire = 0) ->
		fs.stat(app.config.cacheDir + '/' + file, (err, stat) ->
			if stat
				if expire != 0
					expire = Math.round(stat.mtime.getTime() / 1000) + stat.mtime.getTimezoneOffset() * 60 + expire
				
				date = new Date()
				now = Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60
				if expire == 0 or expire >= now
					fs.readFile(app.config.cacheDir + '/' + file, 'utf8', cb)
				else
					cb(true)
			
			else
				cb(true)
		)
		
	@static_read: (file, cb, expire = 0) ->
		fs.stat(app.config.cacheDir + '/' + file, (err, stat) ->
			if stat
				if expire != 0
					expire = Math.round(stat.mtime.getTime() / 1000) + stat.mtime.getTimezoneOffset() * 60 + expire
				date = new Date()
				now = Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60
				if expire == 0 or expire >= now
					fs.readFile(app.config.cacheDir + '/' + file, 'utf8', cb)
				else
					cb(true)
			
			else
				cb(true)
		)
	
	write: (file, data, cb, expire = 0) -> 
		fs.writeFile(app.config.cacheDir + '/' + file, data, (err) ->
			if err
				fs.mkdir(app.config.cacheDir + '/' + file.split(path.sep)[0], '0777', cb)
			else
				cb(err)
		)
		
	flush: (file, cb) ->
		fs.unlink(app.config.cacheDir + '/' + file, cb)
		
	getNameSpace: (file, cb) ->
		FileAdapter.static_read(FileAdapter.hash(file), cb)
		
	setNameSpace: (file, cb, res) ->
		date = new Date()
		ts = String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)
		@write(FileAdapter.hash(file), ts, (err, response) ->
			if not err
				cb(file, res)
			else
				res(err, response)
		)
	
	flushNameSpace: (file, cb) ->
		date = new Date()
		ts = String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)
		@read(FileAdapter.hash(file), (err, data) =>
			if not err and data != ''
				@deleteNameSpaceCache(app.config.cacheDir + '/' + data, (err, path) ->
					fs.rmdir(path, (err) ->)
				)
			@flush(FileAdapter.hash(file), cb)
		)
		
	deleteNameSpaceCache: (path, cb) ->
		fs.stat(path, (err, stat) =>
			if stat and stat.isDirectory()
				#read the directory		
				fs.readdir(path, (err, files) =>
					pending = files.length
					if not pending
						cb(err, path)  
					files.forEach((file) =>
						if file.substr(0, 1) != '.'
							file = path + '/' + file
							fs.stat(file, (err, stat) =>
								if stat and stat.isFile()
									fs.unlink(file, (err) ->
										if not err 
											if not --pending
												cb(err, path)
									)
								else
									@deleteNameSpaceCache(file, (err, path) ->
										if not --pending
											cb(err, path)
									)
							)
					)
				)
		)