util = require('util')

class Decider
	module.exports = @
	
	constructor: () ->
		@tasks		= {}
		@decisions	= {}		
		@active		= {}
		@jobs		= {}
		@retries	= {}
		@max_retry	= 3
		
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
							MaximumPageSize: 15
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
											#err on WorkflowExecutionTimedOut,
											console.log('Success RespondDecisionTaskCompleted', err, res)
										)
								else
									decision = @decisions.Fail
									console.log("FAIL")
									switch data.eventType
										when 'DecisionTaskTimedOut'
											if not data.input?
												''#close
										when 'ActivityTaskFailed'
											'' # do something to report error
										when 'ActivityTaskCanceled'
											'' # do something to report error
										when 'ActivityTaskTimedOut'
											'' #retry
												
									###app.options.swf.connect.RespondDecisionTaskCompleted({TaskToken: taskToken, Decisions: decision}, (err, res) ->	
											#success on ActivityTaskTimedOut,
											console.log('Fail RespondDecisionTaskCompleted', err, res)
										)###
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
		templates =
			ScheduleActivityTask								:
				scheduleActivityTaskDecisionAttributes			: 
					activityType								: 
						name									: 'required'
						version									: 'required'
					activityId									: 'required'
					input										: 'optional'
					taskList									:
						name									: 'required'
					scheduleToCloseTimeout						: '86400'
					scheduleToStartTimeout						: '86400'
					startToCloseTimeout							: '86400'
					heartbeatTimeout							: '86400'
			ContinueAsNewWorkflowExecution						:
				continueAsNewWorkflowExecutionDecisionAttributes:
					executionStartToCloseTimeout				: '86400'
					taskStartToCloseTimeout						: '86400'
					input										: 'optional'
					childPolicy									: 'REQUEST_CANCEL'
			CompleteWorkflowExecution							: {}
					
		for own key,value of decisions
			try
				@decisions[key] = @verifyType(templates, value)
			catch err
				app.logger(err)
		
	verifyType: (templates, decision) ->					
		for tmp in decision
			if templates[tmp.decisionType]?
				app.modules.lib.Functions.checkValue(tmp, templates[tmp.decisionType], tmp.decisionType, @constructor.name)
		
	getData: (history) ->
		console.log("HISTORY", util.inspect(history, false, 10))
		data = 
			lastTask	: null
			input		: null
			status		: null
			reason		: null
			details		: null
			cause		: null
			eventType	: null
			retries		: 0
		
		# get lastTask
		lookFor = ['ActivityTaskScheduled'
			, 'StartChildWorkflowExecutionInitiated'
			, 'WorkflowExecutionContinuedAsNew'
			, 'WorkflowExecutionStarted'
		]
		for activity, i in history
			for event in lookFor
				if activity.eventType == event
					attributes = event.charAt(0).toLowerCase() + event.substr(1) + 'EventAttributes'
					data.lastTask = activity[attributes].taskList.name
					break
					
			break if data.lastTask?
		
		lastActivity	= history[2]
		data.eventType	= lastActivity.eventType
		
		# get status
		attributes = lastActivity.eventType.charAt(0).toLowerCase() + lastActivity.eventType.substr(1) + 'EventAttributes'
		if /completed/i.test(lastActivity.eventType)
			data.status = 'completed'
		else if /(scheduled|initiated|continued|signaled|started)/i.test(lastActivity.eventType)
			data.status = 'ready'
		else
			data.status = 'failed'
			data.reason	= lastActivity[attributes].reason if lastActivity[attributes].reason?
			data.details= lastActivity[attributes].details if lastActivity[attributes].details?
			data.cause	= lastActivity[attributes].cause if lastActivity[attributes].cause?
		
		# get rest of data
		if history[i]?
			lastActivity	= history[i]
			attributes = lastActivity.eventType.charAt(0).toLowerCase() + lastActivity.eventType.substr(1) + 'EventAttributes'
			if /completed/i.test(lastActivity.eventType)
				data.input	= lastActivity[attributes].result if lastActivity[attributes].result?
			else if /(scheduled|initiated|continued|signaled|started)/i.test(lastActivity.eventType)
				data.input	= lastActivity[attributes].input if lastActivity[attributes].input?
				###if lastActivity[attributes].continuedExecutionRunId?
					runId = lastActivity[attributes].continuedExecutionRunId
					app.options.swf.connect.DescribeWorkflowExecution({
							Domain			: app.config.service
							Execution		:
								workflowId	: @jobs[runId]
								runId		: runId
						}
						, (err, res) =>	
							if not err
								data.retries	= @retries[res.Body.executionInfo.execution.workflowId] += 1
								#data.input		= 
								if data.retries >= @max_retry
									data.status = 'failed'
					)###
			
		return data
		
	startWorkflow: (id, input, domain, name, version, timeout) ->
		average_exec_time = '60'
		app.options.swf.connect.StartWorkflowExecution({
				Domain						: domain
				WorkflowId					: id
				WorkflowType				: 
					name					: name
					version					: version
				ExecutionStartToCloseTimeout: timeout
				TaskStartToCloseTimeout		: timeout
				ChildPolicy					: 'REQUEST_CANCEL'
				Input						: input
			}
			, (err, res) =>
				if not err
					runId = res.Body.runId
					@jobs[runId] = id if not @jobs[runId]?
					@retries[id] = 0 if not @retries[0]?
					
		)
		
	
		