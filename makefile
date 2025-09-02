lint:
	npx prettier --write ./**/*.md
	npx prettier --write ./**/*.yaml

lint-check:
	npx prettier --check ./**/*.md
	npx prettier --check ./**/*.yaml