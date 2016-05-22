########################################################################
# Setup
########################################################################

#
# Check global variables used in this module
#
ifndef Logs
$(error Variable 'Logs' is not defined)
endif
ifndef LogDir
$(error Variable 'LogDir' is not defined)
endif

#
# Hidden directory for logs
#
$(Logs): | $(LogDir)

$(LogDir): ; mkdir --parents $@

# vim:ai:sw=4:ts=4:noet:syntax=make
