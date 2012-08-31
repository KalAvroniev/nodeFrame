fs = require('fs')
crypto = require('crypto')
path = require('path')

class FileAdapter
	module.exports = @
		
	tag: (file, folder) ->
		file = folder + '/' + file
		
	@hash: (file) ->
		file = crypto.createHash('md5').update(file).digest('hex')
	
	hashTag: (file, folder) ->
		@tag(FileAdapter.hash(file), folder)
	
	read: (file, cb) ->
		fs.readFile(app.config.cacheDir + '/' + file, 'utf8', cb)
		
	@static_read: (file, cb) ->
		fs.readFile(app.config.cacheDir + '/' + file, 'utf8', cb)
	
	write: (file, data, cb) -> 
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
		@write(FileAdapter.hash(file), ts, (err) ->
			if not err
				#fs.mkdir(app.config.cacheDir + '/' + ts, '0777', (err) ->
				#	if not err
				#cb(file, (err, data) ->
				#	console.log(err, res)
				#	res(err, data)
				#)
				cb(file, res)
				#)
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