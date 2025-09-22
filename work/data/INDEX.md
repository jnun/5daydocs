# Test & Sample Data

Repository for test data, sample files, and data fixtures used in development and testing.

## Purpose

This folder contains:
- Test datasets for development
- Sample data for demonstrations
- Mock API responses
- Database seed files
- Configuration examples
- File upload samples

## Organization

### Directory Structure
```
work/data/
├── fixtures/      # Database seed data
├── mocks/        # Mock API responses
├── samples/      # Example files for testing
├── datasets/     # Larger test datasets
└── exports/      # Sample export files
```

### File Naming Convention
```
[type]-[description]-[size].[ext]
```

Examples:
- `users-sample-100.json`
- `products-mock-full.csv`
- `api-response-success.json`
- `upload-test-image.jpg`
- `config-example-dev.yml`

## Data Types

### JSON Data
```json
{
  "metadata": {
    "description": "Sample user data",
    "count": 10,
    "generated": "2024-01-01",
    "purpose": "Testing user import"
  },
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    }
  ]
}
```

### CSV Data
```csv
# users-sample.csv
# Purpose: Test user import functionality
# Generated: 2024-01-01
id,name,email,role
1,"John Doe",john@example.com,admin
2,"Jane Smith",jane@example.com,user
```

### Mock API Responses
```javascript
// api-response-success.json
{
  "status": 200,
  "message": "Success",
  "data": {
    "users": [],
    "pagination": {
      "page": 1,
      "total": 100
    }
  }
}
```

## Data Documentation

Each data file should have accompanying documentation:

### In-File Documentation
- Include metadata in the file itself
- Add comments explaining the structure
- Note any special values or edge cases

### README for Complex Data
For complex datasets, create a README:
```markdown
# Dataset: E-commerce Orders

## File: orders-2024-q1.json

### Structure
- Order ID (unique)
- Customer details
- Product items array
- Payment information
- Shipping status

### Special Cases
- Order #1001: Cancelled order
- Order #1015: International shipping
- Order #1023: Multiple payment methods

### Usage
Import via admin panel or seed script
```

## Security & Privacy

### Sensitive Data Rules
1. **Never use real user data**
2. **Anonymize any production data**
3. **Use fake generators for PII**
4. **No real API keys or passwords**
5. **No actual credit card numbers**

### Safe Test Values
- Emails: `test@example.com`, `user+test@example.com`
- Phones: `555-0100` through `555-0199`
- Credit Cards: Use test card numbers only
- API Keys: `test_key_xxxxx` format
- Passwords: `TestPass123!` (never real ones)

## Generating Test Data

### Tools & Libraries
```bash
# Faker.js for JavaScript
npm install @faker-js/faker

# Python Faker
pip install faker

# Online generators
# - mockaroo.com
# - generatedata.com
# - jsonplaceholder.typicode.com
```

### Example Generator Script
```javascript
// generate-users.js
const { faker } = require('@faker-js/faker');

function generateUsers(count = 10) {
  return Array.from({ length: count }, () => ({
    id: faker.datatype.uuid(),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    avatar: faker.image.avatar(),
    createdAt: faker.date.past()
  }));
}
```

## Using Data in Tests

### Unit Tests
```javascript
const testUsers = require('./work/data/users-sample.json');

describe('User Service', () => {
  it('should import users', () => {
    const result = userService.import(testUsers);
    expect(result.count).toBe(10);
  });
});
```

### Integration Tests
```bash
# Load test data
curl -X POST http://localhost:3000/api/import \
  -H "Content-Type: application/json" \
  -d @work/data/fixtures/users-seed.json
```

## Maintenance

### Regular Tasks
1. **Clean up old data** - Remove unused test files
2. **Update samples** - Keep examples current
3. **Document changes** - Note schema updates
4. **Check file sizes** - Keep repository lean

### Archiving
- Move old datasets to `archived/` subfolder
- Compress large files that are rarely used
- Delete temporary test files regularly

## Quick Commands

```bash
# List all JSON files
find work/data -name "*.json"

# Check total size
du -sh work/data/

# Find large files
find work/data -size +1M

# Pretty print JSON
python -m json.tool work/data/users-sample.json

# Count records in CSV
wc -l work/data/products.csv
```

## Best Practices

1. **Keep it fake** - Never use real production data
2. **Document purpose** - Why this data exists
3. **Version datasets** - Track schema changes
4. **Size appropriately** - Not too large for git
5. **Cover edge cases** - Include boundary values
6. **Make reproducible** - Document or script generation