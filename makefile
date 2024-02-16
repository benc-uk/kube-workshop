# Simple makefile for linting and formatting
# You will need Node installed to use npx

lint: 
	npx prettier --check ./**/*.yaml
	npx prettier --check ./**/*.md

lint-fix: 
	npx prettier --write .