.PHONY: validate help deps install v1 zub package-manager

SCHEMAS_DIR := schemas
SCHEMA_URL := https://yafb.net/schema

zub:
	@mkdir -p .cache; \
	if [ -f .cache/zub_packbase.json ]; then \
		echo "Using cached version"; \
	else \
		echo "Downloading https://zub.javanile.org/packbase.json..."; \
		curl -sL "https://zub.javanile.org/packbase.json" -o .cache/zub_packbase.json; \
	fi; \
	echo "Validating against local packbase-v1.schema.json..."; \
	ajv validate -s packbase-v1.schema.json -d .cache/zub_packbase.json --spec=draft2020 --strict=false --errors=json 2>&1 | tail -n +2 > /tmp/ajv_out.json; \
	if grep -q '"valid":true' /tmp/ajv_out.json 2>/dev/null; then \
		echo ".cache/zub_packbase.json valid"; \
	else \
		echo "Validation failed:"; \
		jq -r '.[] | .params.additionalProperty // (.keyword + " at " + .instancePath)' /tmp/ajv_out.json 2>/dev/null | grep -v '^null$$' | sort -u | sed 's/^/  - Error: /'; \
	fi

package-manager:
	@mkdir -p .cache; \
	if [ -f .cache/package-manager_packbase.json ]; then \
		echo "Using cached version"; \
	else \
		echo "Downloading https://www.javanile.org/package-manager/packbase.json..."; \
		curl -sL "https://www.javanile.org/package-manager/packbase.json" -o .cache/package-manager_packbase.json; \
	fi; \
	echo "Validating against local packbase-v1.schema.json..."; \
	ajv validate -s packbase-v1.schema.json -d .cache/package-manager_packbase.json --spec=draft2020 --strict=false --errors=json 2>&1 | tail -n +2 > /tmp/ajv_out.json; \
	if grep -q '"valid":true' /tmp/ajv_out.json 2>/dev/null; then \
		echo ".cache/package-manager_packbase.json valid"; \
	else \
		echo "Validation failed:"; \
		jq -r '.[] | .params.additionalProperty // (.keyword + " at " + .instancePath)' /tmp/ajv_out.json 2>/dev/null | grep -v '^null$$' | sort -u | sed 's/^/  - Error: /'; \
	fi

deps install:
	@echo "Installing dependencies..."
	npm install -g ajv-cli ajv-formats

validate:
ifndef FILE
	@echo "Error: specify FILE=<remote_url>"
	@echo "Example: make validate FILE=https://example.com/data.json SCHEMA=packbase"
	@exit 1
endif
ifndef SCHEMA
	@echo "Error: specify SCHEMA=<schema_name>"
	@echo "Available schemas: packbase"
	@exit 1
endif
	@mkdir -p $(SCHEMAS_DIR)
	@echo "Downloading schema $(SCHEMA)..."
	@curl -sL "$(SCHEMA_URL)/$(SCHEMA).schema.json" -o $(SCHEMAS_DIR)/$(SCHEMA).schema.json
	@echo "Validating $(FILE)..."
	@ajv validate -s $(SCHEMAS_DIR)/$(SCHEMA).schema.json -d $(FILE) --verbose

clean:
	@rm -rf $(SCHEMAS_DIR)

help:
	@echo "Makefile for JSON schema validation"
	@echo ""
	@echo "Available targets:"
	@echo "  make validate FILE=<url> SCHEMA=<name> - Validate a remote file against a schema"
	@echo "  make zub                              - Validate https://zub.javanile.org/packbase.json with local schema"
	@echo "  make package-manager                 - Validate https://www.javanile.org/package-manager/packbase.json"
	@echo "  make install                         - Install dependencies (npm global)"
	@echo "  make clean                          - Remove downloaded schemas"
	@echo ""
	@echo "Example:"
	@echo "  make validate FILE=https://example.com/data.json SCHEMA=packbase"

push:
	@git config credential.helper 'cache --timeout=3600'
	@git add .
	@git commit -am fix || true
	@git push