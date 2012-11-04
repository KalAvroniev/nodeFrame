class Functions
	module.exports = @
	
	@clone: (obj) ->
		new_obj 		= {}
		new_obj[key] 	= value  for own key,value of obj
		return new_obj