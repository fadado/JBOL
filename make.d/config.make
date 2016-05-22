########################################################################
# Configuration
########################################################################

# We are using some of the newest GNU Make features... so require GNU Make
# version >= 3.82
version_test := $(filter 3.82,$(firstword $(sort $(MAKE_VERSION) 3.82)))
ifndef version_test
$(error Using GNU Make version $(MAKE_VERSION); version >= 3.82 is needed)
endif

# Warn when an undefined variable is referenced.
MAKEFLAGS += --warn-undefined-variables

# Make will not print the recipe used to remake files.
.SILENT:

# Eliminate use of the built-in implicit rules. Also clear out the default list
# of suffixes for suffix rules.
.SUFFIXES:

# Sets the default goal to be used if no targets were specified on the command
# line.
.DEFAULT_GOAL := all

# When it is time to consider phony targets, make will run its recipe
# unconditionally, regardless of whether a file with that name exists or what
# its last-modification time is.
.PHONY: all

# When a target is built all lines of the recipe will be given to a single
# invocation of the shell.
.ONESHELL:

# Default shell: if we require GNU Make, why not require Bash?
SHELL := /bin/bash

# The argument(s) passed to the shell are taken from the variable .SHELLFLAGS.
.SHELLFLAGS := -o errexit -o pipefail -o nounset -c

# Make will delete the target of a rule if it has changed and its recipe exits
# with a nonzero exit status.
.DELETE_ON_ERROR:

########################################################################
# Undefine predefined variables
########################################################################

undefine AR
undefine ARFLAGS
undefine AS
undefine CC
undefine CHECKOUT,v
undefine CO
undefine COFLAGS
undefine COMPILE.C
undefine COMPILE.F
undefine COMPILE.S
undefine COMPILE.c
undefine COMPILE.cc
undefine COMPILE.cpp
undefine COMPILE.def
undefine COMPILE.f
undefine COMPILE.m
undefine COMPILE.mod
undefine COMPILE.p
undefine COMPILE.r
undefine COMPILE.s
undefine CPP
undefine CTANGLE
undefine CWEAVE
undefine CXX
undefine F77
undefine F77FLAGS
undefine FC
undefine GET
undefine LD
undefine LEX
undefine LEX.l
undefine LEX.m
undefine LINK.C
undefine LINK.F
undefine LINK.S
undefine LINK.c
undefine LINK.cc
undefine LINK.cpp
undefine LINK.f
undefine LINK.m
undefine LINK.o
undefine LINK.p
undefine LINK.r
undefine LINK.s
undefine LINT
undefine LINT.c
undefine M2C
undefine OBJC
undefine OUTPUT_OPTION
undefine PC
undefine PREPROCESS.F
undefine PREPROCESS.S
undefine PREPROCESS.r
undefine RM
undefine SUFFIXES
undefine TANGLE
undefine TEX
undefine TEXI2DVI
undefine WEAVE
undefine YACC
undefine YACC.m
undefine YACC.y

# vim:ai:sw=4:ts=4:noet:syntax=make
