#!/bin/bash

echo "Unit tests..."
PATH=$PATH:../app/node_modules/coffee-script/bin 
coffee build-vows.coffee
coffee vows.coffee > vows-results.txt

echo "Selenium tests..."
java -jar selenium/selenium-server-standalone-2.24.1.jar -htmlSuite *firefox http://localhost:8182 selenium/TestSuite.html selenium/results/Firefox.html
java -jar selenium/selenium-server-standalone-2.24.1.jar -htmlSuite *googlechrome http://localhost:8182 selenium/TestSuite.html selenium/results/Chrome.html

echo "Checking results..."
coffee check-results.coffee
out=$?
if [ $out -ne 0 ]; then
   echo "=== SOME TESTS FAILED!"
else
   echo "=== ALL TESTS PASSED"
fi
exit $out
