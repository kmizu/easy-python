# Python Virtual Environment
VENV_DIR = venv
PYTHON = $(VENV_DIR)/bin/python
PIP = $(VENV_DIR)/bin/pip
MKDOCS = $(VENV_DIR)/bin/mkdocs

# Default target
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  setup     - Setup Python virtual environment and install dependencies"
	@echo "  install   - Install dependencies (venv must exist)"
	@echo "  serve     - Start development server with live reload"
	@echo "  build     - Build static site"
	@echo "  clean     - Clean generated files"
	@echo "  format    - Format Python code with black"
	@echo "  lint      - Run flake8 linter"
	@echo "  typecheck - Run mypy type checker"
	@echo "  validate  - Run all code quality checks"
	@echo "  deps      - Show installed dependencies"

# Setup virtual environment and install dependencies
.PHONY: setup
setup: $(VENV_DIR)/bin/activate
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	@echo "Setup complete! Run 'make serve' to start development server"

# Create virtual environment
$(VENV_DIR)/bin/activate:
	python3 -m venv $(VENV_DIR)

# Install dependencies only (assumes venv exists)
.PHONY: install
install:
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

# Start development server
.PHONY: serve
serve:
	@if [ ! -f $(MKDOCS) ]; then \
		echo "MkDocs not found. Run 'make setup' first."; \
		exit 1; \
	fi
	$(MKDOCS) serve --dev-addr=127.0.0.1:8000

# Build static site
.PHONY: build
build:
	@if [ ! -f $(MKDOCS) ]; then \
		echo "MkDocs not found. Run 'make setup' first."; \
		exit 1; \
	fi
	$(MKDOCS) build --clean

# Deploy to GitHub Pages
.PHONY: deploy
deploy:
	@if [ ! -f $(MKDOCS) ]; then \
		echo "MkDocs not found. Run 'make setup' first."; \
		exit 1; \
	fi
	$(MKDOCS) gh-deploy --force

# Clean generated files
.PHONY: clean
clean:
	rm -rf site/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

# Format Python code
.PHONY: format
format:
	$(VENV_DIR)/bin/black code-examples/ exercises/ solutions/ scripts/

# Run linter
.PHONY: lint
lint:
	$(VENV_DIR)/bin/flake8 code-examples/ exercises/ solutions/ scripts/

# Run type checker
.PHONY: typecheck
typecheck:
	$(VENV_DIR)/bin/mypy code-examples/ exercises/ solutions/ scripts/

# Run all validation checks
.PHONY: validate
validate: format lint typecheck
	@echo "All validation checks passed!"

# Show installed dependencies
.PHONY: deps
deps:
	$(PIP) list

# Clean everything including venv
.PHONY: clean-all
clean-all: clean
	rm -rf $(VENV_DIR)

# Create directories if they don't exist
.PHONY: init-dirs
init-dirs:
	mkdir -p code-examples exercises solutions scripts
	mkdir -p docs/stylesheets docs/javascripts

# Validate code examples in markdown files
.PHONY: validate-examples
validate-examples:
	@echo "Validating code examples..."
	$(PYTHON) scripts/validate_examples.py docs/

# Check BNF syntax in documentation
.PHONY: check-bnf
check-bnf:
	@echo "Checking BNF syntax..."
	$(PYTHON) scripts/check_bnf.py docs/
