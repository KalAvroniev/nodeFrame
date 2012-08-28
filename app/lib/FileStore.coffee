fs = require('fs')

class FileStore
	module.exports = @
	
	read: (file, cb) ->
		fs.readFile(file, 'utf8', cb)
	
	write: (file, data, cb) -> 
		fs.writeFile(file, data, cb)