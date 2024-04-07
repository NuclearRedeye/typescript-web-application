
PROJECT := $(notdir $(CURDIR))
NODE_VERSION ?= iron
NGINX_VERSION ?= alpine
PORT ?= 8080

# Build commands
DOCKER := docker run --rm -w=/$(PROJECT) -v $(CURDIR):/$(PROJECT):rw

# Files that when changed should trigger a rebuild.
TS     := $(shell find ./src/ts -type f -name *.ts)
SASS   := $(shell find ./src/scss -type f -name *.scss)
HTML   := $(shell find ./src/html -type f -name *.html)
ASSETS := $(shell find ./src/assets -type f)

# Targets that don't result in output of the same name.
.PHONY: clean \
        distclean \
        lint \
        format \
        test \
        debug \
        release \
        start

# When no target is specified, the default target to run.
.DEFAULT_GOAL := debug

# Target that cleans build output and local dependencies.
distclean: clean
	@rm -rf node_modules

# Target that cleans build output
clean:
	@rm -rf dist

# Target to install Node.js dependencies.
node_modules: package.json
	@echo "Installing dependencies..."
	@npm install
	@touch node_modules

# Target to create the output directories.
dist/debug dist/release:
	@echo "Creating $@..."
	@mkdir -p $(CURDIR)/$@

# Target that creates the specified HTML file by copying it from the src directory.
dist/debug/index.html dist/release/index.html: $(HTML)
	@echo "Creating $@..."
	@cp $(CURDIR)/src/html/$(@F) $@

# Target that creates the assets by copying them from the src directory.
dist/debug/assets dist/release/assets: $(ASSETS)
	@echo "Creating $@..."
	@cp -r $(CURDIR)/src/assets/ $@
	@touch $@

# Target that compiles TypeScript to JavaScript.
dist/debug/index.js: node_modules dist/debug tsconfig.json $(TS)
	@echo "Creating $@..."
	@npx tsc

# Target that compiles SCSS to CSS.
dist/debug/index.css: node_modules dist/debug $(SASS)
	@echo "Creating $@..."
	@npx sass ./src/scss/index.scss $@

# Target that bundles, treeshakes and minifies the JavaScript.
dist/release/index.js: dist/release dist/debug/index.js
	@echo "Creating $@..."
	@npx rollup ./dist/debug/index.js --file $@
	@npx terser -c -m -o $@ $@

# Target that compiles SCSS to CSS.
dist/release/index.css: node_modules dist/release $(SASS)
	@echo "Creating $@..."
	@npx sass --no-source-map ./src/scss/index.scss $@

# Target that checks the code for style/formating issues.
format: node_modules
	@echo "Running style checks..."
	@npx prettier --check .

# Target that lints the code for errors.
lint: node_modules
	@echo "Running linter..."
	@npx eslint ./src

# Target to run all unit tests.
test: node_modules
	@echo "Running unit tests..."
	@npx jest

# Target that builds a debug/development version of the app
debug: dist/debug dist/debug/index.html dist/debug/index.css dist/debug/index.js dist/debug/assets

# Target that builds a release version of the app
release: dist/release dist/release/index.html dist/release/index.css dist/release/index.js dist/release/assets

# Target that 'watches' and rebuilds automatically
watch:
	@echo "Watching for changes..."
	@while true; do $(MAKE) -q || $(MAKE); sleep 1; done

# Target that builds and runs a debug instance of the project.
dev: debug
	@echo "Starting '$(PROJECT)' on 'http://localhost:$(PORT)'..."
	@docker run --rm --name $(PROJECT) -p $(PORT):80 -e NGINX_ENTRYPOINT_QUIET_LOGS=1 -v '$(CURDIR)/.nginx/nginx.conf:/etc/nginx/nginx.conf:ro' -v $(CURDIR)/dist/debug:/usr/share/nginx/html/:ro nginx:$(NGINX_VERSION)