# Easy management of tests and examples

########################################################################
# Configuration
########################################################################

# We are using some of the newest GNU Make features... so require GNU
# Make version >= 3.82
version_test := $(filter 3.82,$(firstword $(sort $(MAKE_VERSION) 3.82)))
ifndef version_test
$(error GNU Make version $(MAKE_VERSION); version >= 3.82 is needed)
endif

# Remove defaults
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKEFLAGS += --warn-undefined-variables
.SUFFIXES:

# Entry point
.DEFAULT_GOAL := all
.PHONY: all

# Shell and shell options
SHELL := /bin/bash
.SHELLFLAGS := -o errexit -o pipefail -o nounset -c

# Don't leave incomplete targets
.DELETE_ON_ERROR:

# Make will not print the recipe used to remake files.
.SILENT:

########################################################################
# Targets and files
########################################################################

# Tests to check
Tests := $(wildcard tests/*.test)

# Sentinel targets simulating the tests are done
LogDir := .logs
Logs := $(subst tests/,$(LogDir)/,$(Tests:.test=.log))

LIB=fadado.github.io
STR=$(LIB)/string
GEN=$(LIB)/generator

########################################################################
# Rules
########################################################################

#JQ=/usr/bin/jq
JQ=/usr/local/bin/jq

# Warning: only `dnf`!
setup:
	sudo dnf -y install jq
	sudo dnf -y install PyYAML

# Hidden directory for logs
$(Logs): | $(LogDir)
$(LogDir): ; mkdir --parents $@

# Tests output is saved in a log file
$(LogDir)/%.log: tests/%.test
	echo '>>>' $< '<<<' | tee $@
	$(JQ) -L./fadado.github.io --run-tests $<	\
		| tee --append $@	\
		| grep --invert-match '^Testing'
	grep --quiet '^\*\*\*' $@ && touch $< || true

# Other dependencies
$(LogDir)/prelude.log: $(LIB)/prelude.jq
$(LogDir)/sets.log: $(LIB)/prelude.jq $(LIB)/types.jq
$(LogDir)/math.log: $(LIB)/math.jq

# generators
$(LogDir)/stream.log: $(GEN)/generator.jq
$(LogDir)/choice.log: $(GEN)/choice.jq $(GEN)/generator.jq $(GEN)/chance.jq 
$(LogDir)/sequence.log: $(GEN)/sequence.jq $(LIB)/prelude.jq
$(LogDir)/chance.log: $(GEN)/chance.jq $(LIB)/prelude.jq

# string
$(LogDir)/ascii.log: $(STR)/ascii.jq $(STR)/ascii.json $(LIB)/prelude.jq
$(LogDir)/latin1.log: $(STR)/latin1.jq $(STR)/latin1.json $(LIB)/prelude.jq
$(LogDir)/regexp.log: $(STR)/regexp.jq $(LIB)/prelude.jq $(STR)/string.jq
$(LogDir)/string.log: $(STR)/string.jq $(LIB)/prelude.jq $(STR)/ascii.jq $(STR)/ascii.json
$(LogDir)/snobol.log: $(STR)/snobol.jq $(LIB)/prelude.jq  $(STR)/string.jq

# Default target
all: $(Logs)

########################################################################
# Utilities
########################################################################

.PHONY: clean clobber check help

clean:
	rm --force -- $(LogDir)/*.log

clobber: clean
	test -d $(LogDir) && rmdir --parents $(LogDir) || true

check: clean all

# Show targets
.PHONY: help
help:
	echo 'Targets:';					\
	$(MAKE) --print-data-base --just-print 2>&1		\
	| grep -v '^[mM]akefile'				\
	| awk '/^[^ \t.%][-A-Za-z0-9_]*:/ { print $$1 }'	\
	| sort --unique						\
	| sed 's/:\+$$//'					\
	| pr --omit-pagination --indent=4 --width=80 --columns=4

########################################################################
# Examples
########################################################################

.PHONY: bogussort cross cut dice newton nondet nqbrute nqsmart octcode script seconds sendmoremoney series shuffle snqbrute triple
EE: bogussort cross cut dice newton nondet nqbrute nqsmart octcode script seconds sendmoremoney series shuffle snqbrute triple

bogussort: ; @examples/$@.jq
cross: ; @examples/$@.jq
cut: ; @examples/$@.jq
dice: ; @examples/$@.jq
newton: ; @examples/$@.jq
nondet: ; @examples/$@.jq
nqbrute: ; @examples/$@.jq
nqsmart: ; @examples/$@.jq
octcode: ; @examples/$@.jq
script: ; @examples/$@.jq
seconds: ; @examples/$@.jq
sendmoremoney: ; @examples/$@.jq
series: ; @examples/$@.jq
shuffle: ; @examples/$@.jq
snqbrute: ; @examples/$@.jq
triple: ; @examples/$@.jq

# vim:ai:sw=8:ts=8:noet:syntax=make
