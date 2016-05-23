# Easy management of tests and examples

include make.d/config.make

########################################################################
# Parameters (redefine as you like)
########################################################################

InstallPrefix := /usr/local

########################################################################
# Targets and files
########################################################################

# Tests to check
Tests := $(wildcard tests/*.test)

# Sentinel targets simulating the tests are done
LogDir := .logs
Logs := $(subst tests/,$(LogDir)/,$(Tests:.test=.log))

# Scripts to manage JSON and YAML
Scripts := j2y y2j yq

########################################################################
# Rules
########################################################################

# Create auxiliar directories
include make.d/setup.make

# Tests output is saved in a log file
$(LogDir)/%.log: tests/%.test
	echo '>>>' $< '<<<' | tee $@
	jq --run-tests $< \
		| tee --append $@ \
		| grep --invert-match '^Testing' || true
	grep --quiet '^\*\*\*' $@ && touch $<
	echo

# Other dependencies
$(LogDir)/series.log:  lib/series.jq lib/stream.jq lib/control.jq
$(LogDir)/sets.log:    lib/sets.jq
$(LogDir)/streams.log: lib/stream.jq lib/control.jq
$(LogDir)/strings.log: lib/string.jq

# Default target
all: $(Logs)

########################################################################
# Utilities
########################################################################

.PHONY: clean clobber check test install uninstall

clean:
	rm --force -- $(LogDir)/*.log

clobber: clean
	-[[ -d $(LogDir) ]] && rmdir --parents $(LogDir)

check test: clean all

install:
	sudo install --verbose --compare --mode 555 \
		$(addprefix bin/,$(Scripts)) $(InstallPrefix)/bin

uninstall:
	sudo rm --force --verbose -- \
		$(addprefix $(InstallPrefix)/bin/,$(Scripts))

########################################################################
# Examples
########################################################################

# Conversions
Y2J := bin/y2j
J2Y := bin/j2y
YQ  := bin/yq

.PHONY: cross script star yaml

cross:
	./examples/cross.jq --arg word1 'computer' --arg word2 'center'

script:
	./examples/script.sh 'on' 'one motion is optional'

star:
	$(SHELL) examples/star.sh

yaml:
	echo 'No news is good news...'
	for e in examples/yaml-[0-9][0-9].sh; do \
		echo $$e; $(SHELL) $$e; \
	done

# vim:ai:sw=4:ts=4:noet:syntax=make
