util 	= require('util')
fs	 	= require('fs')
async 	= require('async')
shell 	= require('shelljs')

mongoose = require('mongoose')

class Profiler
	module.exports = @
	
	constructor: (@log = true) ->
		@start 	= {}
		@end 	= {}
		
	startProfiling: (cb) ->
		@start.memory 	= process.memoryUsage().rss
		@start.time 	= process.hrtime()
		@cpuUsage(@start, cb)
		
	stopProfiling: (cb) ->
		@end.memory 	= process.memoryUsage().rss
		@end.time 		= process.hrtime(@start.time)
		@cpuUsage(@end, cb)

	store: (id) ->
		schema = new mongoose.Schema(
				memory: Number
				time: 	Array
				cpu: 	Number
				count: 	Number
				_id: 	String
		)

		Performance = app.pstore.model('Performance', schema)

		memory 		= @end.memory - @start.memory
		time 		= @end.time
		cpu 		= 0
		if @start.cpu
			total_diff 	= (@end.cpu.total - @start.cpu.total) * @end.cpu.cpus * 100
			user_diff 	= @end.cpu.user - @start.cpu.user
			if total_diff > 0
				cpu =  parseFloat(user_diff / total_diff)
			
		Performance.findOne({_id: id}, (err, res) =>
			return app.logger(err, 'warn') if err
			if res?
				tmp = 
					memory: @calcAvg(res.memory, res.count, memory)
					time: 	[@calcAvg(res.time[0], res.count, time[0]), @calcAvg(res.time[1], res.count, time[1])]
					cpu: 	@calcAvg(res.cpu, res.count, cpu)
					count: 	res.count + 1
				if @log
					Performance.update({_id: id}, tmp, {upsert:true}, (err, num, raw) ->
						console.log(tmp)
					)
					
				console.log(tmp)
			else
				tmp = new Performance({_id: id, memory: memory, time: time, cpu: cpu, count: 1})
				if @log
					tmp.save((err) ->
						console.log(tmp)
					)
					
				console.log(tmp)
		)
	
	cpuUsage: (usage, cb) ->
		async.parallel(
			{
				total: (callback) ->
					fs.readFile('/proc/stat', (err, data) =>
						if not err
							dRaw 	= data.toString().split('\n')[0].split(' ')
							total 	= 0
							count	 = 0
							for time in dRaw
								time = parseInt(time)
								if time
									count++
									total += time
								if count >= 4
									break

							callback(null, total)
						else
							callback(err)
					)
				, user: (callback) ->
					fs.readFile('/proc/' + process.pid + '/stat', (err, data) =>
						if not err
							dRaw = data.toString().split(' ')
							user = parseInt(dRaw[13]) + parseInt(dRaw[14])
							callback(null, user)
						else
							callback(err)
					)
				, cpus: (callback) ->
					shell.silent(true)
					shell.exec('cat /proc/cpuinfo | grep processor | wc -l', (code, output) ->
						if not code
  							callback(null, parseInt(output))
					)
			}, 
			(err, results) ->
				if not err
					usage.cpu = results
					if cb
						cb(usage)
		)

	calcAvg: (cur_avg, count, new_val) ->
			return (cur_avg * count + new_val) / (count + 1)