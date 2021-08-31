MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.PHONY:

# Environment switches
REGISTRY ?=
CANONICAL_NAME ?= node
IMAGE_NAME ?= hausgold/$(CANONICAL_NAME)
IMAGE_REF ?= 15
IMAGE_URI := $(IMAGE_NAME):$(IMAGE_REF)
TEST_CONTAINER_NAME ?= $(CANONICAL_NAME)-test

# Host binaries
CURL ?= curl
DOCKER ?= docker
EXIT ?= exit
GREP ?= grep
SLEEP ?= sleep
TEST ?= test
TIME ?= time

# Define a retry helper
define retry
	if eval "$(1)"; then exit 0; fi; \
	for i in 1; do sleep 10s; echo "Retrying $$i..."; \
		if eval "$(1)"; then exit 0; fi; \
	done; \
	exit 1
endef

all:
	# mDNS enabled official/node
	#
	# build          Build a development snapshot of the image
	# test           Test the built Docker image
	# publish        Push the new Docker image to the registry
	#
	# shell          You can start an individual session of the image for tests
	# clean          Clean the current development snapshot

build: clean
	# Build the Docker image
	@$(TIME) $(DOCKER) build --no-cache -t "$(IMAGE_NAME):dev" .

test:
	# Test the built Docker image
	#
	# Not yet implemented.

publish:
	# Push the new Docker image to the registry
	@$(DOCKER) tag "$(IMAGE_NAME):dev" "$(IMAGE_URI)"
	@$(call retry,$(TIME) $(SHELL) -c '$(DOCKER) push $(IMAGE_URI)')

shell:
	# Start an individual test session of the image
	@$(DOCKER) run --rm -it "$(IMAGE_NAME):dev" bash

clean:
	# Clean the current development snapshot
	@$(DOCKER) rmi --force "$(IMAGE_NAME):dev" || true
