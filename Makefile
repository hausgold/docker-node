MAKEFLAGS += --warn-undefined-variables -j1
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.PHONY:

# Files
TAGS ?= $(filter-out README.md config docs,$(subst /,,$(wildcard */)))
UPDATE_TAGS := $(TAGS:%=update-%)

# Host binaries
CP ?= cp

all:
	# Configuration Maintenance
	#
	# update          Update the configuration on all image tag directories

update: $(UPDATE_TAGS)

$(UPDATE_TAGS): TAG=$(@:update-%=%)
$(UPDATE_TAGS):
	# Update the configuration for the "$(TAG)" image tag directory
	@$(CP) -ar config/* $(TAG)/config/
