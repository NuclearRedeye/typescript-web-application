
PROJECT := $(notdir $(CURDIR))
NODE_VERSION ?= fermium
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
.DEFAULT_GOAL := start

# Target that cleans build output and local dependencies.
distclean: clean
	@rm -rf node_modules

# Target that cleans build output
clean:
	@rm -rf out

# Target to install Node.js dependencies.
node_modules: package.json
	@echo "Installing dependencies..."
	@$(DOCKER) node:$(NODE_VERSION) npm install
	@touch node_modules

# Target to create the output directories.
out/debug out/release:
	@echo "Creating $@..."
	@mkdir -p $(CURDIR)/$@

# Target that creates the specified HTML file by copying it from the src directory.
out/debug/index.html out/release/index.html: $(HTML)
	@echo "Creating $@..."
	@cp $(CURDIR)/src/html/$(@F) $@

# Target that creates the assets by copying them from the src directory.
out/debug/assets out/release/assets: $(ASSETS)
	@echo "Creating $@..."
	@cp -r $(CURDIR)/src/assets/ $@
	@touch $@

# Target that compiles TypeScript to JavaScript.
out/debug/index.js: node_modules out/debug tsconfig.json $(TS)
	@echo "Creating $@..."
	@$(DOCKER) node:$(NODE_VERSION) npx tsc

# Target that compiles SCSS to CSS.
out/debug/index.css: node_modules out/debug $(SASS)
	@echo "Creating $@..."
	@$(DOCKER) node:$(NODE_VERSION) npx sass ./src/scss/index.scss $@

# Target that bundles, treeshakes and minifies the JavaScript.
out/release/index.js: out/release out/debug/index.js
	@echo "Creating $@..."
	@$(DOCKER) node:$(NODE_VERSION) npx rollup ./out/debug/index.js --file $@
	@$(DOCKER) node:$(NODE_VERSION) npx terser -c -m -o $@ $@

# Target that compiles SCSS to CSS.
out/release/index.css: node_modules out/release $(SASS)
	@echo "Creating $@..."
	@$(DOCKER) node:$(NODE_VERSION) npx sass --no-source-map ./src/scss/index.scss $@

# Target that checks the code for style/formating issues.
format: node_modules
	@echo "Running style checks..."
	@$(DOCKER) node:$(NODE_VERSION) npx prettier --check .

# Target that lints the code for errors.
lint: node_modules
	@echo "Running linter..."
	@$(DOCKER) node:$(NODE_VERSION) npx eslint ./src --ext .js,.ts

# Target to run all unit tests.
test: node_modules
	@echo "Running unit tests..."
	@$(DOCKER) node:$(NODE_VERSION) npx jest

# Target that builds a debug/development version of the app
debug: out/debug out/debug/index.html out/debug/index.css out/debug/index.js out/debug/assets

# Target that builds a release version of the app
release: out/release out/release/index.html out/release/index.css out/release/index.js out/release/assets

# Target that builds and runs a debug instance of the project.
start: debug
	@echo "Starting '$(PROJECT)' on 'http://localhost:$(PORT)'..."
	@docker run --rm --name $(PROJECT) -p $(PORT):80 -e NGINX_ENTRYPOINT_QUIET_LOGS=1 -v $(CURDIR)/out/debug:/usr/share/nginx/html/:ro nginx:alpine