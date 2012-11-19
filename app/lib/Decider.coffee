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
							MaximumPageSize: 10
							ReverseOrder: true
						}
						, (err, res) =>
							#return cb(err) if err
							taskToken = res.Body.taskToken if res.Body.taskToken?
							if taskToken?
								data = @getData(res.Body.events)	
								console.log("DATA", data)
								if data.status == 'completed' or data.status == 'ready'
									decision = if @decisions[data.lastTask]? then @decisions[data.lastTask] else null
									if decision?
										decision[0].scheduleActivityTaskDecisionAttributes.input = data.input if decision[0].scheduleActivityTaskDecisionAttributes?
										app.options.swf.connect.RespondDecisionTaskCompleted({TaskToken: taskToken, Decisions: decision}, (err, res) ->	
											console.log(err, res)
										)
								else
									app.options.swf.connect.RespondDecisionTaskCompleted({TaskToken: taskToken, Decisions: decision}, (err, res) ->	
											console.log(err, res)
										)
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
		console.log("HISTORY", history)
		data = 
			lastTask	: null
			input		: null
			status		: null
			reason		: null
			details		: null
			cause		: null
			eventType	: null
		
		# get lastTask
		lookFor = ['ActivityTaskScheduled'
			, 'StartChildWorkflowExecutionInitiated'
			, 'WorkflowExecutionContinuedAsNew'
			, 'WorkflowExecutionStarted'
		]
		for activity in history
			for event in lookFor
				if activity.eventType == event
					attributes = event.charAt(0).toLowerCase() + event.substr(1) + 'EventAttributes'
					data.lastTask = activity[attributes].taskList.name
					break					
		
		lastActivity	= history[2]
		data.eventType	= lastActivity.eventType
		
		attributes = lastActivity.eventType.charAt(0).toLowerCase() + lastActivity.eventType.substr(1) + 'EventAttributes'
		if /completed/i.test(lastActivity.eventType)
			data.status = 'completed'
			data.input	= lastActivity[attributes].result if lastActivity[attributes].result
		else if /(scheduled|initiated|continued|signaled|started)/i.test(lastActivity.eventType)
			data.status = 'ready'
			data.input	= lastActivity[attributes].input if lastActivity[attributes].input
		else
			data.status = 'failed'
			data.reason	= lastActivity[attributes].reason if lastActivity[attributes].reason
			data.details= lastActivity[attributes].details if lastActivity[attributes].details
			data.cause	= lastActivity[attributes].cause if lastActivity[attributes].cause
			
		return data
		
	
		