PNPM := corepack pnpm

.PHONY: install dev build preview deploy typecheck types

install:
	$(PNPM) install

dev:
	$(PNPM) dev

build:
	$(PNPM) build

preview:
	$(PNPM) preview

deploy:
	$(PNPM) deploy

typecheck:
	$(PNPM) typecheck

types:
	$(PNPM) exec emdash types
