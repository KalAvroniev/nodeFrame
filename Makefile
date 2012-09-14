REPORTER = spec

test: 
	@NODE_ENV=test mocha \
		--reporter $(REPORTER) \
		--compilers coffee:coffee-script \

test-w:
	@NODE_ENV=test mocha \
		--compilers coffee:coffee-script \
		--reporter $(REPORTER) \
		--watch

build:
	@coffee -c -o src app
	@rsync -az --exclude '*.coffee' app/ src

app-cov: build
	@jscoverage src app-cov --no-instrument=node_modules

test-cov: app-cov
	@COVERAGE=1 $(MAKE) test REPORTER=html-cov > coverage.html
	rm -rf app-cov src

.PHONY: test test-w