GridModel = require('../../models/GridModel.coffee').GridModel

class exports.Controller

	validate: {
	}
	
	options: {
		"requireUserSession": true
	}
	
	run: (req) ->
		grid = new GridModel()
		
		# header
		grid.addHeaderLabel([
			{
				'action': 'stickyswitch'
			},
			{
				'title': 'Basic domain info',
				'span': 2
			}
			#{
			#	'title': 'Price/value info',
			#	'span': 4
			#},
			#{
			#	'title': 'Performance info',
			#	'span': 2
			#},
			#{
			#	'title': 'Domain registration info',
			#	'span': 3
			#},
			#{
			#	'title': 'Extension info',
			#	'span': 3
			#}
		])
		
		# columns
		grid.addMasterColumn({
			'title': 'Bulk',
			'columns': {
				'selected': {
					'formatter': 'checkbox'
				},
				'star': {
					'formatter': 'star'
				}
			}
		})
		
		grid.addMasterColumn({
			'title': 'Top action(s)',
			'columns': {
				'topactions': {
					'formatter': 'topactions',
					'filter': {
						'type': 'menu',
						'title': 'sort by?'
						'values': ['Action 1', 'Action 2', 'Action 3']
					}
				}
			}
		})
		
		grid.addMasterColumn({
			'title': 'Domain title',
			'columns': {
				'domain': {
					'sortable': true,
					'filter': {
						'type': 'textcombo'
					}
				}
			}
		})
		
		# data
		for i in [1,2,3]
			grid.addRecord({
				'selected': false,
				'star': false,
				'domain': '353cards.com'
			})
		
		return req.success(grid.result())
