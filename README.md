# s

Repository for publishing JSON validation schemas for my projects.

## Available Schemas

- **packbase-v1.schema.json** - Schema for validating base configurations
  - URL: https://yafb.net/s/packbase-v1.schema.json

## Usage

To validate a remote JSON file against a schema:

```bash
make validate FILE=<remote_file_url> SCHEMA=packbase
```

Example:
```bash
make validate FILE=https://example.com/data.json SCHEMA=packbase
```

## Requirements

- [ajv-cli](https://github.com/ajv-validator/ajv-cli) installed globally
- `npm install -g ajv-cli ajv-formats`