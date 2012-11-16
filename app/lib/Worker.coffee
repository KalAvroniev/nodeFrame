util = require('util')

class Worker
	module.exports = @
	
	constructor: () ->
		@tasks	= {}
		@active = {}
		
	pollForTask: (single) ->
		Object.keys(@tasks).forEach((id) =>
			@active[id] = {} if not @active[id]?
			@tasks[id].forEach((task) =>
				if not single? or single == task
					if not @active[id][task]?
						@active[id][task] = 0

					@active[id][task] += 1				
					app.options.swf.connect.PollForActivityTask({Domain: app.config.service, TaskList: {name: task}, Identity: id}, (err, res) =>
						#return cb(err) if err
						taskToken = res.Body.taskToken if res.Body.taskToken?
						if taskToken?
							input = res.Body.input
							app.options.swf.connect.RespondActivityTaskCompleted({TaskToken: taskToken, Result: input + " Result as String"}, (err, res) ->	)
						else
							@active[id][task] -= 1
							return if @active[id][task] > 1

						@pollForTask(task)
					)
			)
		)
	
	addTasks: (id, tasks) ->
		if @tasks[id]?
			@tasks[id].concat(tasks)
			@tasks[id].unique()
		else
			@tasks[id] = tasks