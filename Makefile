SHELL := /bin/bash
.DEFAULT_GOAL := help

ifneq (,$(wildcard .env))
include .env
export
endif

.PHONY: help contracts-build contracts-test anvil deploy-local deploy-sepolia frontend-install frontend-dev frontend-build frontend-start frontend-env-example

help: ## Show available commands
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'

contracts-build: ## Compile smart contracts
	forge build

contracts-test: ## Run smart contract tests
	forge test -vvv

anvil: ## Start a local Anvil node
	anvil

deploy-local: ## Deploy contracts to local Anvil using PRIVATE_KEY from .env
	@test -n "$(PRIVATE_KEY)" || (echo "Missing PRIVATE_KEY in .env" && exit 1)
	forge script script/Deploy.s.sol \
		--rpc-url http://127.0.0.1:8545 \
		--broadcast

deploy-sepolia: ## Deploy contracts to Sepolia using PRIVATE_KEY and SEPOLIA_RPC_URL from .env
	@test -n "$(PRIVATE_KEY)" || (echo "Missing PRIVATE_KEY in .env" && exit 1)
	@test -n "$(SEPOLIA_RPC_URL)" || (echo "Missing SEPOLIA_RPC_URL in .env" && exit 1)
	forge script script/Deploy.s.sol \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--broadcast

frontend-install: ## Install frontend dependencies
	cd frontend && npm install

frontend-dev: ## Start the frontend dev server
	cd frontend && npm run dev

frontend-build: ## Build the frontend
	cd frontend && npm run build

frontend-start: ## Start the frontend production server
	cd frontend && npm run start

frontend-env-example: ## Copy frontend env example if .env.local is missing
	@if [ ! -f frontend/.env.local ]; then cp frontend/.env.example frontend/.env.local && echo "Created frontend/.env.local"; else echo "frontend/.env.local already exists"; fi
