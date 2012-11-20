class Functions
	module.exports = @
	
	@clone: (obj) ->
		new_obj 		= {}
		new_obj[key] 	= value  for own key,value of obj
		return new_obj
		
	@checkValue: (obj, template, name, type = '') ->
		for own key, value of template
			if typeof value == 'object'
				if obj[key]?
					Functions.checkValue(obj[key], value, name, type)
				else						
					throw new app.error('Missing ' + key + ' look at ' + type + ' template for ' + name, @, 'error')
					
			else
				switch value
					when 'required'
						throw new app.error('Missing ' + key + ' look at ' + type + ' template ' + name, @, 'error') if not obj[key]?.length
					when 'optional'
						obj[key] = null if not obj[key]?.length
					else
						obj[key] = value if not obj[key]?.length
						
		return obj