lint: 
	npx prettier --check ./**/*.yaml
	npx prettier --check ./**/*.md

lint-fix: 
	npx prettier --write .