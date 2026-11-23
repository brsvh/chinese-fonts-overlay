.DEFAULT_GOAL := all
.DELETE_ON_ERROR:

SOURCE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BUILD_DIR ?= $(SOURCE_DIR)/build
REFERENCE ?=
SOURCE_REVISION ?=
SYSTEM ?=
GUILE ?= guile
MAKEINFO ?= makeinfo
export MAKEINFO

override BUILD_DIR := $(abspath $(BUILD_DIR))
override REFERENCE := $(if $(REFERENCE),$(abspath $(REFERENCE)))
SCHEME = $(GUILE) --no-auto-compile -L "$(SOURCE_DIR)/../site/module" \
	-L "$(SOURCE_DIR)/module"

.PHONY: all check

all:
	$(SCHEME) "$(SOURCE_DIR)/build-aux/build.scm" \
	  "$(SOURCE_DIR)" "$(BUILD_DIR)" "$(REFERENCE)" \
	  "$(SOURCE_REVISION)" "$(SYSTEM)"

check: all
	$(SCHEME) "$(SOURCE_DIR)/build-aux/check.scm" \
	  "$(BUILD_DIR)/manual"
