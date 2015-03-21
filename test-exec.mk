# Evaluates to the empty string if $1, when executed by the shell, fails.
# Otherwise evaluates to a non-empty string.
#
define test-exec
$(strip $(shell if $1 >/dev/null; then echo OK; fi))
endef

# Test cases
#
ifneq ($(strip $(call test-exec,true)),OK)
$(error test-exec true FAIL)
endif
ifneq ($(call test-exec,false),)
$(error test-exec false FAIL)
endif
