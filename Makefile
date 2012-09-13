REPORTER = spec

test: 
	@NODE_ENV=test mocha \
		--compilers coffee:coffee-script \
		--reporter $(REPORTER) \

test-w:
	@NODE_ENV=test mocha \
		--compilers coffee:coffee-script \
		--reporter $(REPORTER) \
		--watch

test-cov: app-cov
	@COVERAGE=1 $(MAKE) test REPORTER=html-cov > coverage.html

app-cov:
	@jscoverage app app-cov --no-instrument=node_modules

.PHONY: test test-w