.PHONY: run
run:
	hugo serve -w

.DEFAULT_GOAL := run
default: run
