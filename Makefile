################################################################################
# CONFIGURATION ################################################################
################################################################################

### NPM ########################################################################
NPM_EXE ?= npm
PACKAGE_JSON ?= package.json
NODE_MODULES ?= node_modules
MODULE_DIR ?= module
NPM_ARGS ?= --silent

# PACKAGING ####################################################################
PACKAGE_VERSION ?= $(shell $(NODE_EXE) -e "console.log(require('./$(PACKAGE_JSON)').version)")
PACKAGE_NAME ?= $(shell $(NODE_EXE) -e "console.log(require('./$(PACKAGE_JSON)').name)")
TMP_PACKAGE_DIR ?= packaging-$(PACKAGE_NAME)-$(PACKAGE_VERSION)-tmp
PACKAGE_DIR ?= $(PACKAGE_NAME)-v$(PACKAGE_VERSION)
TEST_MODULE_DIR ?= ../testing-module-install

### JS/COFFEE ##################################################################
COFFEE_EXE ?= ./node_modules/.bin/coffee
NODE_EXE ?= node
COFFEE_COMPILE ?= $(COFFEE_EXE) -c
COFFEE_COMPILE_ARGS ?=
COFFEE_SRCS ?= $(wildcard lib/*.coffee)
COFFEE_TEST_SRCS ?= $(wildcard test/*.coffee)
COFFEE_JS ?= ${COFFEE_SRCS:.coffee=.js}

### MOCHA ######################################################################
MOCHA_EXE ?= ./node_modules/.bin/mocha
MOCHA_TESTS ?= $(wildcard test/test-*.coffee)
MOCHA_TEST_PATTERN ?=
MOCHA_TIMEOUT ?=-t 2000
MOCHA_TEST_ARGS  ?= -R list --compilers coffee:coffee-script/register $(MOCHA_TIMEOUT) $(MOCHA_TEST_PATTERN)

### JSCOVERAGE #################################################################
JSCOVERAGE_EXE ?= ./node_modules/.bin/node-jscoverage
JSCOVERAGE_REPORT ?= docs/coverage.html
JSCOVERAGE_TMP_DIR ?=  ./jscov-tmp
LIB_COV ?= lib-cov
LIB ?= lib
MOCHA_COV_ARGS  ?= -R html-cov --compilers coffee:coffee-script/register --globals "_\$$jscoverage"

### MARKDOWN ###################################################################
MARKDOWN_EXE ?= ./node_modules/.bin/marked
MARKDOWN_SRCS ?= $(shell find . -type f -name '*.md' | grep -v node_modules | grep -v module | grep -v common-dustjs-helpers-v.*)
MARKDOWN_HTML ?= ${MARKDOWN_SRCS:.md=.html}
# LITCOFFEE_SRCS ?= $(shell find . -type f -name '*.litcoffee' | grep -v node_modules | grep -v module)
# LITCOFFEE_HTML ?= ${LITCOFFEE_SRCS:.litcoffee=.html}
MARKDOWN_EXE_ARGS ?= -gfm
MARKDOWN_PREFIX ?= "<html><body>"
MARKDOWN_SUFFIX ?= "</body></html>"

################################################################################
# TARGETS ######################################################################
################################################################################

.SUFFIXES:;
.PHONY: all clean really-clean npm install clean-node-modules really-clean-node-modules tes  clean-test-module-install clean-module module test-module-install coverage clean-coverage docco markdown clean-docco clean-markdown docs clean-docs publish coffee litcoffee clean-litcoffee;

### ALL ########################################################################
all: test;
clean: clean-node-modules clean-test-module-install clean-module clean-coverage clean-docs clean-js;
really-clean: clean really-clean-node-modules;

### JS / COFFEE ################################################################
js: $(NODE_MODULES) $(COFFEE_JS)
coffee: js; # an alias
.SUFFIXES: .js .coffee
.coffee.js:
	$(COFFEE_COMPILE) $(COFFEE_COMPILE_ARGS) $<
$(COFFEE_JS_OBJ): $(NODE_MODULES) $(COFFEE_SRCS)
clean-js:
	rm -f $(COFFEE_JS)

### NPM ########################################################################
module: test coverage docs
	mkdir -p $(MODULE_DIR)
	cp README.md $(MODULE_DIR)
	cp LICENSE $(MODULE_DIR)
	cp -r lib $(MODULE_DIR)
	cp $(PACKAGE_JSON) $(MODULE_DIR)
	mv module $(PACKAGE_DIR)
	tar -czf $(PACKAGE_DIR).tgz $(PACKAGE_DIR)
test-module-install: clean-test-module-install module
	mkdir -p ${TEST_MODULE_DIR}
	cd ${TEST_MODULE_DIR}
	npm install "$(CURDIR)/$(PACKAGE_DIR).tgz"
	@(node -e "require('assert').ok(require('common-dustjs-helpers').exportTo !== null);" &&  echo "\n\033[1;32m It worked! \033[0m\n" && cd $(CURDIR) && rm -rf ${TEST_MODULE_DIR})
$(NODE_MODULES): $(PACKAGE_JSON)
	$(NPM_EXE) prune
	$(NPM_EXE) --silent install
	touch $(NODE_MODULES) # touch the module dir so it looks younger than `package.json`
npm: $(NODE_MODULES) # an alias
install: $(NODE_MODULES) # an alias
clean-node-modules:; $(NPM_EXE) prune
really-clean-node-modules:; rm -rf $(NODE_MODULES)
clean-test-module-install:; rm -rf ${TEST_MODULE_DIR}
clean-module:
	rm -rf ${MODULE_DIR}
	rm -rf $(PACKAGE_DIR)
	rm -rf $(PACKAGE_DIR).tgz
publish: module test-module-install; $(NPM_EXE) publish $(PACKAGE_DIR).tgz

### MOCHA ######################################################################
test: test-mocha
test-mocha: $(NODE_MODULES) $(MOCHA_TESTS) $(COFFEE_SRCS) $(COFFEE_TEST_SRCS);
	$(MOCHA_EXE) $(MOCHA_TEST_ARGS) $(MOCHA_TESTS)
coverage: js
	rm -rf $(JSCOVERAGE_TMP_DIR)
	rm -rf $(LIB_COV)
	mkdir -p $(JSCOVERAGE_TMP_DIR)
	cp -r $(LIB)/* $(JSCOVERAGE_TMP_DIR)/.
	$(JSCOVERAGE_EXE) -v $(JSCOVERAGE_TMP_DIR) $(LIB_COV)
	mkdir -p `dirname $(JSCOVERAGE_REPORT)`
	$(MOCHA_EXE) $(MOCHA_COV_ARGS) $(MOCHA_TESTS) > $(JSCOVERAGE_REPORT)
	rm -rf $(JSCOVERAGE_TMP_DIR)
	rm -rf $(LIB_COV)
clean-coverage:; rm -rf  $(JSCOVERAGE_TMP_DIR) $(LIB_COV) $(JSCOVERAGE_REPORT)

### DOCS #######################################################################
docs: markdown litcoffee docco

.SUFFIXES: .html .md
.md.html:
	(echo $(MARKDOWN_PREFIX) > $@) && ($(MARKDOWN_EXE) $(MARKDOWN_EXE_ARGS) $< >> $@) && (echo $(MARKDOWN_SUFFIX) >> $@)
$(MARKDOWN_HTML_OBJ): $(MARKDOWN_SRCS)

.SUFFIXES: .html .litcoffee
.litcoffee.html:
	(echo $(MARKDOWN_PREFIX) > $@) && ($(MARKDOWN_EXE) $(MARKDOWN_EXE_ARGS) $< >> $@) && (echo $(MARKDOWN_SUFFIX) >> $@)
$(LITCOFFEE_HTML_OBJ): $(LITCOFFEE_SRCS)

markdown: $(MARKDOWN_HTML)
litcoffee: $(LITCOFFEE_HTML)

docco: $(COFFEE_SRCS) $(NODE_MODULES)
	rm -rf docs/docco
	mkdir -p docs
	mv docs docs-temporarily-renamed-so-docco-doesnt-clobber-it
	docco $(COFFEE_SRCS)
	mv docs docs-temporarily-renamed-so-docco-doesnt-clobber-it/docco
	mv docs-temporarily-renamed-so-docco-doesnt-clobber-it docs
clean-docs: clean-docco clean-markdown;
clean-docco:; rm -rf docs/docco
clean-markdown:; rm -rf $(MARKDOWN_HTML)
clean-litcoffee:; rm -rf $(LITCOFFEE_HTML)

################################################################################
# EOF ##########################################################################
################################################################################
