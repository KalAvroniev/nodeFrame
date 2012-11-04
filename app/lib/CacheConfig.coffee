
class CacheConfig
	module.exports = @
	
	constructor: () -> 
		store 	= app.config.cache.config
		@CC 	= app.modules.lib.Cache.Config[store.charAt(0).toUpperCase() + store.substr(1) + 'Store']
		@cc 	= new @CC()
		@bucket = app.config.aws.bucket
			
	read: (file, modified = null, cb) ->
		@cc.read(@bucket, file, modified, cb)
			
	write: (file, data, cb) ->
		@cc.write(@bucket, file, data, cb)	