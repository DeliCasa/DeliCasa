# DeliCasa Development Tools

This directory contains development and testing utilities for the DeliCasa project.

## Scripts

### `scripts/diagnostic-test.js`

Comprehensive diagnostic tool for testing the BridgeServer integration:

- Tests authentication flow between Next.js Client and BridgeServer
- Validates JWT token generation and verification
- Checks endpoint accessibility and authorization
- Supports both development and production environments

Usage:

```bash
cd tools
node scripts/diagnostic-test.js [environment]
# environment: development (default) | production
```

### `scripts/integration-test.js`

Integration testing script for verifying end-to-end functionality:

- Tests complete data flow from client to server
- Validates database connectivity and operations
- Useful for CI/CD pipeline testing

Usage:

```bash
cd tools
node scripts/integration-test.js
```

### `scripts/generate-test-token.js`

Utility for generating test JWT tokens for development and testing:

- Creates valid JWT tokens for testing authentication
- Useful for manual testing and debugging

Usage:

```bash
cd tools
node scripts/generate-test-token.js
```

## Dependencies

The tools have their own package.json with required dependencies:

- `jsonwebtoken` - JWT token handling
- `node-fetch` - HTTP requests for testing

To install dependencies:

```bash
cd tools
npm install
```

## Usage in CI/CD

These tools can be integrated into CI/CD pipelines for automated testing:

```yaml
# Example GitHub Actions step
- name: Run Integration Tests
  run: |
    cd tools
    npm install
    node scripts/integration-test.js
```
