#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_NAME = cache-simulator
PYTHON_VERSION = 3.13
PYTHON_INTERPRETER = python

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Delete all compiled Python files
.PHONY: clean
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*pytest_cache" -exec rm -rf {} +
	find . -type d -name "*mypy_cache" -exec rm -rf {} +
	find . -type d -name "*ruff_cache" -exec rm -rf {} +

## Validate rules and format using pre-commit-hooks, ruff and mypy
.PHONY: validate
validate:
	poetry run pre-commit run --all-files

## Install pre-commit hooks
.PHONY: hooks
hooks:
	poetry run pre-commit autoupdate
	poetry run pre-commit clean
	poetry run pre-commit install
	poetry run pre-commit install -f --hook-type commit-msg --hook-type pre-commit

## Generate baseline file for detect-secrets
.PHONY: scan
scan:
	poetry run detect-secrets scan > .secrets.baseline

## Run tests
.PHONY: test
test:
	poetry run pytest --cov

## Set up Python interpreter environment
.PHONY: create_environment
create_environment:
	conda create --name $(PROJECT_NAME) python=$(PYTHON_VERSION) -y
	@echo ">>> conda env created. Activate with:\nconda activate $(PROJECT_NAME)"
	
#################################################################################
# PROJECT RULES                                                                 #
#################################################################################



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys; \
lines = '\n'.join([line for line in sys.stdin]); \
matches = re.findall(r'\n## (.*)\n[\s\S]+?\n([a-zA-Z_-]+):', lines); \
print('Available rules:\n'); \
print('\n'.join(['{:25}{}'.format(*reversed(match)) for match in matches]))
endef
export PRINT_HELP_PYSCRIPT

help:
	@$(PYTHON_INTERPRETER) -c "${PRINT_HELP_PYSCRIPT}" < $(MAKEFILE_LIST)
