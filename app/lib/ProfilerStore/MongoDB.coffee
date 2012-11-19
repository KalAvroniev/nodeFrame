mongoose = require('mongoose')

class MongoDB
	module.exports = @
	
	constructor: () ->
		schema = new mongoose.Schema(
				memory	: Number
				time	: Array
				cpu		: Number
				count	: Number
				_id		: String
		)
		
		@Performance = app.pstore.model('Performance', schema)
		
	read: (id, cb) ->
		@Performance.findOne({_id: id}, (err, res) ->
			if cb
				cb(err, res)
		)
	
	write: (data, update = false, cb) ->
		if update
			id = data['_id']
			delete data['_id']
			@Performance.update({_id: id}, data, {upsert:true}, (err, num, raw) ->
				if cb
					cb(err, num, raw)
			)
		else
			tmp = new @Performance(data)
			tmp.save((err) ->
				if cb
					cb(err)
			)
	