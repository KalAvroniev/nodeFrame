#!/bin/bash

echo "Unit tests..."
coffee build-vows.coffee
coffee vows.coffee > vows-results.txt

echo "Selenium tests..."
java -jar selenium/selenium-server-standalone-2.24.1.jar -htmlSuite *firefox http://localhost:8181 selenium/TestSuite.html selenium/Result.html

echo "Checking results..."
coffee check-results.coffee
out=$?
if [ $out -ne 0 ]; then
   echo "=== SOME TESTS FAILED!"
else
   echo "=== ALL TESTS PASSED"
fi
exit $out
