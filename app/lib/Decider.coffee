util = require('util')

class Decider
	module.exports = @
	
	constructor: () ->
		@tasks		= {}
		@decisions	= {}		
		@active		= {}
		
	pollForTask: (single) =>
		Object.keys(@tasks).forEach((id) =>
			@active[id] = {} if not @active[id]?
			@tasks[id].forEach((task) =>
				if not single? or single == task
					if not @active[id][task]?
						@active[id][task] = 0

					@active[id][task] += 1
					app.options.swf.connect.PollForDecisionTask({
							Domain: app.config.service
							TaskList: {name: task}
							Identity: id
							MaximumPageSize: 5
							ReverseOrder: true
						}
						, (err, res) =>
							#return cb(err) if err
							taskToken = res.Body.taskToken if res.Body.taskToken?
							if taskToken?
								data = @getData(res.Body.events)	
								if data.status == 'completed'
									decision = if @decisions[data.lastEvent]? then @decisions[data.lastEvent] else null
									if decision?
										decision[0].scheduleActivityTaskDecisionAttributes.input = data.input if decision[0].scheduleActivityTaskDecisionAttributes?
										app.options.swf.connect.RespondDecisionTaskCompleted({TaskToken: taskToken, Decisions: decision}, (err, res) ->	)	
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
				
	addDecisions: (decisions) ->
		@decisions = app.modules.lib.Functions.clone(decisions)
		
	getData: (history) ->
		data = 
			lastEvent:	null
			input:		null
			status:		null
		
		activity = history[2]
		
		if history[4]?
			data.lastEvent = history[4].activityTaskScheduledEventAttributes.taskList.name
		else
			data.lastEvent = activity.workflowExecutionStartedEventAttributes.taskList.name
		
		switch activity.eventType
			when 'WorkflowExecutionStarted'
				data.status = 'completed'
				data.input = activity.workflowExecutionStartedEventAttributes.input
			when 'ActivityTaskCompleted'
				data.status = 'completed'
				data.input = activity.activityTaskCompletedEventAttributes.result
			when 'ActivityTaskCanceled'
				data.status = 'canceled'
			when 'ActivityTaskFailed'
				data.status	= 'failed'
				
		return data
		
	
		