class exports.GridModel

	constructor: () ->
		@d = {
			headers: [],
			columns: [],
			records: [],
			actions: {}
		}

	addHeaderLabel: ( data ) ->
		@d.headers.push( data )

	addMasterColumn: ( data ) ->
		@d.columns.push( data )

	addAction: ( data ) ->
		@d.actions[ data.id ] = data

	addRecord: ( data ) ->
		@d.records.push( data )

	result: () ->
		return @d