util 	= require('util')
fs	 	= require('fs')
async 	= require('async')
shell 	= require('shelljs')



class Profiler
	module.exports = @
	
	constructor: (@print = false) ->
		@start 	= {}
		@end 	= {}
		@storage	= new app.modules.lib.ProfilerStore[app.config.profiler.charAt(0).toUpperCase() + app.config.profiler.substr(1)]()
		
	startProfiling: (cb) ->
		@start.memory 	= process.memoryUsage().rss
		@start.time 	= process.hrtime()
		@cpuUsage(@start, cb)
		
	stopProfiling: (cb) ->
		@end.memory 	= process.memoryUsage().rss
		@end.time 		= process.hrtime(@start.time)
		@cpuUsage(@end, cb)

	store: (id) ->
		memory		= @end.memory - @start.memory
		time 		= @end.time
		cpu 		= 0
		if @start.cpu
			total_diff 	= (@end.cpu.total - @start.cpu.total) * @end.cpu.cpus * 100
			user_diff 	= @end.cpu.user - @start.cpu.user
			if total_diff > 0
				cpu =  parseFloat(user_diff / total_diff)
			
		@storage.read(id, (err, res) =>
			return app.logger(err, 'warn') if err
			if res?
				tmp = 
					memory: @calcAvg(res.memory, res.count, memory)
					time: 	[@calcAvg(res.time[0], res.count, time[0]), @calcAvg(res.time[1], res.count, time[1])]
					cpu:	@calcAvg(res.cpu, res.count, cpu)
					count: 	res.count + 1
					_id:	id
				
				@storage.write(tmp, true)
				if @print or process.env.NODE_ENV != 'production'
					app.logger('Performance: ' + util.inspect(tmp))
			else
				tmp =
					memory: memory
					time:	time
					cpu:	cpu 
					count:	1
					_id:	id
					
				@storage.write(tmp)
				if @print or process.env.NODE_ENV != 'production'	
					app.logger('Performance: ' + util.inspect(tmp))
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
					Profiler.numCpus((code, output) ->
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
			
	# Get cpu count for the server
	@numCpus: (cb) ->
		shell.silent(true)
		shell.exec('cat /proc/cpuinfo | grep processor | wc -l', (code, output) ->
			cb(code, output)
		)
		
	# Get memory count for the server in KB
	@totalMemory: (cb) ->
		shell.silent(true)
		shell.exec('cat /proc/meminfo | awk "/MemTotal/ {print \\\$2}"', (code, output) ->
			cb(code, output)
		)