# Makefile — compatibility forwarder to `just`
# The canonical task runner for this repo is now `just` (see justfile).
.DEFAULT_GOAL := help

%:
	@just "$@"

help:
	@just --list
