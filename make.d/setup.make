########################################################################
# Setup
########################################################################

#
# Check global variables
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
$(firstword $(Logs)): | $(LogDir)

$(LogDir): ; mkdir --parents $@

# vim:ai:sw=4:ts=4:noet:syntax=make
