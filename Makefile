# FitDB Makefile (WIP)
# This Makefile provides commands to initialize and seed the FitDB database

# Default database configuration (can be overridden via command line or environment variables)
# Usage: make init DB_HOST=localhost DB_PORT=3306 DB_USER=root DB_PASSWORD=mypass
# Note: .env file support will be added post-MVP
DB_HOST ?= localhost
DB_PORT ?= 3306
DB_USER ?= root
DB_PASSWORD ?=
DB_NAME ?= fitdb

# Python interpreter
PYTHON := python3

# Directories
SQL_DIR := sql
SCRIPTS_DIR := scripts
DATA_DIR := data
CSV_DIR := $(DATA_DIR)/csvs

# Seed size options: tiny, small, medium, large, huge
# tiny=10, small=100, medium=1000, large=10000, huge=100000 members
SEED_SIZE ?= tiny

.PHONY: help init _clean build seed clean reset full-setup

# Default target - show help
help:
	@echo "FitDB Makefile Commands:"
	@echo ""
	@echo "  make init              - Initialize database connection and create database"
	@echo "                          Options: DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME"
	@echo "                          Example: make init DB_HOST=localhost DB_PORT=3306 DB_USER=root DB_PASSWORD=secret"
	@echo ""
	@echo "  make build             - Clean and run build.sql to create tables, views, procedures, etc."
	@echo "                          (Automatically drops existing database and roles first)"
	@echo ""
	@echo "  make seed              - Generate and load seed data into database"
	@echo "                          Options: SEED_SIZE=[tiny|small|medium|large|huge]"
	@echo "                          - tiny:   10 members (default)"
	@echo "                          - small:  100 members"
	@echo "                          - medium: 1000 members"
	@echo "                          - large:  10000 members"
	@echo "                          - huge:   100000 members"
	@echo "                          Example: make seed SEED_SIZE=small"
	@echo ""
	@echo "  make clean             - Drop the database and roles (WARNING: destroys all data)"
	@echo ""
	@echo "  make reset             - Clean and rebuild database (init + build)"
	@echo ""
	@echo "  make full-setup        - Complete setup: init + build + seed"
	@echo "                          Example: make full-setup SEED_SIZE=medium"
	@echo ""
	@echo "Current Configuration:"
	@echo "  DB_HOST:      $(DB_HOST)"
	@echo "  DB_PORT:      $(DB_PORT)"
	@echo "  DB_USER:      $(DB_USER)"
	@echo "  DB_NAME:      $(DB_NAME)"
	@echo "  SEED_SIZE:    $(SEED_SIZE)"

# Initialize database - creates the database if it doesn't exist
init:
	@echo "Initializing database..."
	@$(PYTHON) $(SCRIPTS_DIR)/init.py \
		--host $(DB_HOST) \
		--port $(DB_PORT) \
		--user $(DB_USER) \
		--password "$(DB_PASSWORD)" \
		--database $(DB_NAME)
	@echo "Database initialized successfully!"

# Internal clean target (non-interactive) - used by build
_clean:
	@echo "Cleaning database and roles..."
	@mysql -h $(DB_HOST) -P $(DB_PORT) -u $(DB_USER) $(if $(DB_PASSWORD),-p$(DB_PASSWORD),) \
		-e "DROP DATABASE IF EXISTS \`$(DB_NAME)\`; \
		DROP USER IF EXISTS 'fitdb_admin'@'%'; \
		DROP USER IF EXISTS 'fitdb_app'@'%'; \
		DROP ROLE IF EXISTS r_member, r_plus_member, r_trainer, r_manager, r_front_desk, r_floor_manager, r_admin_gym, r_super_admin;"
	@echo "Database and roles dropped successfully!"
	@echo ""

# Build database schema - runs build.sql (automatically cleans first)
build: _clean
	@echo "=========================================="
	@echo "Building database schema..."
	@echo "=========================================="
	@echo ""
	@set -o pipefail; \
	cd $(SQL_DIR) && ../$(SCRIPTS_DIR)/expand_sources.sh build.sql 2>&1 | mysql -h $(DB_HOST) -P $(DB_PORT) -u $(DB_USER) $(if $(DB_PASSWORD),-p$(DB_PASSWORD),) --local-infile 2>&1 | tee /tmp/fitdb_build.log; \
	exit_code=$$?; \
	if [ $$exit_code -ne 0 ]; then \
		echo ""; \
		echo "=========================================="; \
		echo "ERROR: Database build failed (exit code: $$exit_code)!"; \
		echo "=========================================="; \
		echo "Last SOURCE file being loaded:"; \
		grep "^-- Loading:" /tmp/fitdb_build.log | tail -1 || echo "Unable to determine source file"; \
		echo ""; \
		echo "Line number from error:"; \
		grep "at line" /tmp/fitdb_build.log | tail -1; \
		echo ""; \
		echo "Last 30 lines of error output:"; \
		tail -30 /tmp/fitdb_build.log; \
		exit 1; \
	fi
	@echo ""
	@echo "=========================================="
	@echo "Database schema built successfully!"
	@echo "=========================================="

# Generate seed data and load it into database
seed:
	@echo "=========================================="
	@echo "Seeding database (size: $(SEED_SIZE))..."
	@echo "=========================================="
	@echo ""
	@echo "Cleaning old CSV files..."
	@rm -rf $(CSV_DIR)/*.csv 2>/dev/null || true
	@mkdir -p $(CSV_DIR)
	@echo "Generating seed data..."
	@$(PYTHON) $(DATA_DIR)/generate_seed.py \
		--size $(SEED_SIZE) \
		--output $(CSV_DIR)
	@echo "Loading seed data into database..."
	@mysql -h $(DB_HOST) -P $(DB_PORT) -u $(DB_USER) $(if $(DB_PASSWORD),-p$(DB_PASSWORD),) --local-infile $(DB_NAME) < $(SQL_DIR)/bulkcopy.sql
	@echo ""
	@echo "=========================================="
	@echo "Seed data loaded successfully!"
	@echo "=========================================="

# Clean database - drops the database (interactive, with confirmation)
clean:
	@echo "WARNING: This will drop the '$(DB_NAME)' database and all its data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(MAKE) _clean; \
	else \
		echo "Aborted."; \
	fi

# Reset database - clean and rebuild
reset: clean init build

# Full setup - initialize, build, and seed
full-setup: init build seed
	@echo ""
	@echo "=========================================="
	@echo "FitDB setup complete!"
	@echo "=========================================="
	@echo "Database: $(DB_NAME)"
	@echo "Host:     $(DB_HOST):$(DB_PORT)"
	@echo "Seed:     $(SEED_SIZE)"
	@echo "=========================================="

# Check if required Python packages are installed
check-deps:
	@echo "Checking Python dependencies..."
	@$(PYTHON) -c "import mysql.connector" 2>/dev/null || (echo "ERROR: mysql-connector-python not installed. Run: pip3 install -r requirements.txt" && exit 1)
	@$(PYTHON) -c "import faker" 2>/dev/null || (echo "ERROR: faker not installed. Run: pip3 install -r requirements.txt" && exit 1)
	@echo "All required dependencies are installed!"

# Install Python dependencies
install-deps:
	@echo "Installing Python dependencies..."
	@$(PYTHON) -m pip3 install -r requirements.txt
	@echo "Dependencies installed successfully!"

