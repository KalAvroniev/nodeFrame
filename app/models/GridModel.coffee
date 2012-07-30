class exports.GridModel

	constructor: () ->
		@d = {
			'headers': [],
			'columns': [],
			'records': []
		}

	addHeaderLabel: (data) ->
		@d.headers.push(data)

	addMasterColumn: (data) ->
		@d.columns.push(data)

	addRecord: (data) ->
		@d.records.push(data)

	result: () ->
		return @d
