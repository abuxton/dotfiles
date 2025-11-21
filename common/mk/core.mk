# https://github.com/krisnova/Makefile/blob/main/Makefile

-include .env
REPO_TOP=$(shell git rev-parse --show-toplevel 2>/dev/null || echo ${HOME} )
CORE=${REPO_TOP}/common/mk/core.mk
BIN_DIR=${REPO_TOP}/common/bin

all: help


aws-env: ## generate AWS environment
	@echo "Review your `AWS_*` env credentials."
	${BIN_DIR}/mk_aws >> .env
	env | grep AWS_ | sort >> .env
	echo "source .env after review || edit."
	cat .env

whoami: ## show current user
	@echo "You are: $$(whoami)"
	@echo 'Digital Adept:'
	npx digitaladept

asciinema: ## show asciinema help
	@if command -v asciinema >/dev/null 2>&1; then \
		echo "asciinema is installed. Showing help:"; \
		command asciinema --help; \
	else \
		echo "asciinema is not installed. Please install it from https://asciinema.org/"; \
		exit 1; \
	fi

cheat: ## show cheat sheet h
	path=":help"
	@curl -q https://cheat.sh/${path}

agg: ## show aag help
	@if ! command -v agg >/dev/null 2>&1; then \
		echo "agg is not installed. Please install it from https://github.com/asciinema/agg"; \
		exit 1; \
	else \
		echo "agg is installed. Showing help:"; \
		command agg --help; \
	fi

.PHONY: help

help:  ## Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(CORE)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'
