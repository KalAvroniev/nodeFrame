REPORTER = dot

test: 
	@NODE_ENV=test mocha \
		--reporter $(REPORTER) \

test-w:
	@NODE_ENV=test mocha \
		--reporter $(REPORTER) \
		--watch

test-cov: app-cov
	@COVERAGE=1 $(MAKE) test REPORTER=html-cov > coverage.html

app-cov:
	@jscoverage app app-cov

.PHONY: test test-w