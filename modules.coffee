fs	 = require('fs')
path_module = require('path')
util = require('util')

class Modules
	module.exports = @
	
	@registerModules = (path, modules) ->
		parent = path.split(path_module.sep).pop()
		if parent != ''
			modules[parent] = {}		
		stat = fs.statSync(path)
		if stat and stat.isDirectory()
			#read the directory
			files = fs.readdirSync(path)
			#push files before folders
			files.sort((a, b) ->
				aIsFile = fs.statSync(path + '/' + a).isFile()
				bIsFile = fs.statSync(path + '/' + b).isFile()
				if aIsFile and bIsFile
					return 0
				else if aIsFile and not bIsFile
					return -1
				else
					return 1
			)		
			files.forEach((file) =>
				if file.substr(0, 1) != '.'
					file = path + '/' + file
					stat = fs.statSync(file)
					if stat and stat.isFile()
						if not /Bootstrap\.coffee/.test(file) #|app\.js|modules\.coffee|start_node\.sh
							ext = path_module.extname(file)
							module = path_module.basename(file, ext)
							modules[parent][module] = require(file)

					else
						if not /views|node_modules|config/.test(file)
							if parent != ''
								Modules.registerModules(file, modules[parent])
							else
								Modules.registerModules(file, modules)

			)