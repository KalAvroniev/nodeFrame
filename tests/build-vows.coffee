JsonRpcServer = require('../app/lib/JsonRpcServer.coffee').JsonRpcServer
fs = require('fs')

# start the JSON-RPC server
jsonRpcServer = new JsonRpcServer()

# register all the controllers
jsonRpcServer.registerMethods('../app/api')
console.log("JSON-RPC Server ready.\n")

# iterate the controllers to find all the tests
console.log("Building tests...")

fout = "vows = require('vows')\nassert = require('assert')\nTestUtils = require('./TestUtils.coffee').TestUtils\n"
fout += "JsonRpcServer = require('../app/lib/JsonRpcServer.coffee').JsonRpcServer\n\n"
fout += "jsonRpcServer = new JsonRpcServer()\n"
fout += "jsonRpcServer.registerMethods('../app/api')\n\n"
fout += "vows.describe('Test Suite')\n	.addBatch({\n"
for endpoint, v of jsonRpcServer.registeredMethods
	controller = new (require('../app/api/' + endpoint + '.coffee').Controller)
	totalTests = 0
	fout += "\t\t'" + endpoint + "':\n"
	fout += "\t\t\t'topic': () ->\n"
	fout += "\t\t\t\treturn new (require('../app/api/" + endpoint + ".coffee').Controller)\n\n"

	for testName, testMethod of controller
		if testName.substr(0, 4) != 'test'
			continue

		++totalTests
		fout += "\t\t\t'" + testName + "': (topic) ->\n"
		fout += "\t\t\t\ttopic." + testName + "(new TestUtils('" + endpoint + "', topic, jsonRpcServer))\n\n"
		
	if totalTests > 0
		console.log("  " + endpoint + " (" + totalTests + " tests)")

fout += "\t})\n\t.run()\n"

# write file
fs.writeFile("vows.coffee", fout, (err) ->
    if err
        console.error(err)
        process.exit(1)
    console.log("Done\n")
)
