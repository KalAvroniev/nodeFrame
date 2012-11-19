fs = require('fs')
path_module = require('path')
util = require('util')
asunc = require('async')

class Modules
	module.exports = @
	
	#recursively go through a folder and register all modules it could find
	@registerModulesSync = (path, modules) ->
		parent = path.split(path_module.sep).pop()
		if parent != ''
			modules[parent] = {}		
		stat = fs.statSync(path)
		if stat and stat.isDirectory()
			#read the directory
			files = fs.readdirSync(path)
			#push files before folders
			files.sort((a, b) ->
				aIsFile = fs.statSync(path + path_module.sep + a).isFile()
				bIsFile = fs.statSync(path + path_module.sep + b).isFile()
				if aIsFile and bIsFile
					return 0
				else if aIsFile and not bIsFile
					return -1
				else
					return 1
			)
			files.forEach((file) =>
				if file.substr(0, 1) != '.'
					file = path + path_module.sep + file
					stat = fs.statSync(file)
					if stat and stat.isFile()
						if not /Bootstrap/.test(file)
							ext						= path_module.extname(file)
							module					= path_module.basename(file, ext)
							modules[parent][module] = require(file)

					else
						if not /views|node_modules|config/.test(file)
							if parent != ''
								Modules.registerModulesSync(file, modules[parent])
							else
								Modules.registerModulesSync(file, modules)
			)
		else
			stat = fs.statSync(file)
			if stat and stat.isFile()
				if not /Bootstrap/.test(file)
					ext						= path_module.extname(file)
					module					= path_module.basename(file, ext)
					modules[parent][module] = require(file)
