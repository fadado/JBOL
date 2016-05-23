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
	./examples/star.jq --arg alphabet '01' --argjson ordered true  \
		| head --lines 20 >/tmp/star1.tmp || true
	./examples/star.jq --arg alphabet '01' --argjson ordered false \
		| head --lines 20 >/tmp/star2.tmp || true
	echo '=======+==========='
	echo 'ORDERED|NOT ORDERED'
	echo '=======+==========='
	paste /tmp/star[12].tmp

yaml:
	# Several tests using yq (no output is expected)
	echo 'No news is good news...'
	# data/hardware.json == ($(J2Y) data/hardware.json | $(Y2J))
	jq --null-input --raw-output \
		--slurpfile j1 data/hardware.json \
		--slurpfile j2 <($(J2Y) data/hardware.json | $(Y2J)) \
		'if $$j1 == $$j2
		 then empty
	 	 else "Failed conversion JSON <==> YAML"
		 end'
	# jq q JSON == yq q YAML
	diff <(jq --sort-keys '.store.book[1]' data/store.json | bin/j2y) \
		 <($(YQ) --sort-keys '.store.book[1]' data/store.yaml)
	# yq q YAML == s
	[[ $$($(YQ) -J -r .store.bicycle.color data/store.yaml) == red ]] \
		|| echo 1>&2 'Error using yq'

# vim:ai:sw=4:ts=4:noet:syntax=make
