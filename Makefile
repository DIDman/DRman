SHELL := /bin/bash
.DEFAULT_GOAL := run_local

run_local:
	./gradlew install
	source ~/.drman/bin/drman-init.sh && chmod +x ~/.drman/src/*.sh