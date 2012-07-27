fs = require('fs')

# check unit tests
fs.readFile('vows-results.txt', 'ascii', (err, data) ->
	if err
		console.error("Could not open file: %s", err)
		process.exit(1)
		
	console.log(data)
	if data.match(/Broken/)
		console.error("Vows tests failed.")
		process.exit(1)
	
	# check selenium
	checkResult = (path) =>
		fs.readFile(path, 'ascii', (err, data) ->
			if err
				console.error("Could not open file: %s", err)
				process.exit(1)
			
			if data.match(/<td>failed<\/td>/)
				console.error("Selenium tests failed.")
				process.exit(1)
		)
		
	checkResult('selenium/results/Firefox.html')
	checkResult('selenium/results/Chrome.html')
)
