# Examples

## Overview

This directory contains reusable code patterns, implementation examples, and reference snippets. These examples are intended to demonstrate best practices and provide a starting point for common development tasks.

## Usage

Use these examples as a reference when implementing new features or functionality. Copy and adapt the code snippets to fit your specific needs.

# Code Examples & Snippets

Reusable code patterns, implementation examples, and reference snippets.

## Purpose

This folder contains working code examples that demonstrate:
- Common implementation patterns
- API usage examples
- Configuration templates
- Integration samples
- Best practice implementations

## Organization

### By Type
```
work/examples/
├── api/           # API integration examples
├── auth/          # Authentication patterns
├── components/    # UI component examples
├── config/        # Configuration templates
├── scripts/       # Script examples
└── utils/         # Utility functions
```

### File Naming
```
[feature]-[language].[ext]
```

Examples:
- `pagination-react.jsx`
- `auth-middleware-node.js`
- `database-config.yml`
- `api-client-python.py`

## Example File Format

Include context and usage instructions:

```javascript
/**
 * File: user-authentication.js
 * Purpose: JWT authentication middleware example
 * Usage: Add to Express routes requiring authentication
 * Dependencies: jsonwebtoken, bcrypt
 *
 * Example:
 *   app.get('/protected', authenticate, (req, res) => {
 *     res.json({ user: req.user });
 *   });
 */

const jwt = require('jsonwebtoken');

function authenticate(req, res, next) {
  const token = req.header('Authorization')?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
}

module.exports = authenticate;
```

## Documentation Headers

Every example should include:
1.  **Purpose** - What this code does
2.  **Usage** - How to implement it
3.  **Dependencies** - Required packages/libraries
4.  **Example** - Working usage example
5.  **Notes** - Important considerations

## Categories of Examples

### API Integration
- REST client implementations
- GraphQL queries
- WebSocket connections
- Third-party service integrations

### Authentication & Security
- JWT implementation
- OAuth flows
- Password hashing
- Rate limiting

### Data Processing
- CSV parsing
- JSON transformation
- Data validation
- Batch processing

### UI Components
- Form validation
- Modals and dialogs
- Data tables
- Navigation patterns

### Configuration
- Environment setup
- Database connections
- Build configurations
- Docker setups

## Using Examples in Tasks

Reference examples when implementing features:

```markdown
# Task: Add User Authentication

## Implementation
Use authentication pattern from:
work/examples/auth/jwt-middleware.js

Adapt for our user model...
```

## Quality Guidelines

### Code Quality
- **Working code** - Must run without errors
- **Clean code** - Well-formatted and readable
- **Commented** - Explain complex logic
- **Tested** - Include basic test cases if applicable

### Documentation
- **Clear purpose** - Why this example exists
- **Usage instructions** - How to implement
- **Dependencies listed** - What's required
- **Edge cases noted** - Known limitations

## Maintenance

### Adding Examples
1.  Identify reusable pattern
2.  Extract and generalize code
3.  Add documentation header
4.  Test independently
5.  Place in appropriate subfolder

### Updating Examples
1.  Test changes in isolation
2.  Update documentation
3.  Note breaking changes
4.  Reference in CHANGELOG if significant

### Retiring Examples
1.  Mark as deprecated in header
2.  Provide alternative approach
3.  Keep for reference period
4.  Archive when no longer referenced

## Quick Commands

```bash
# Find all JavaScript examples
find work/examples -name "*.js"

# Search for specific pattern
grep -r "authentication" work/examples/

# List examples by category
ls work/examples/*/

# Copy example to current directory
cp work/examples/auth/jwt-middleware.js ./
```

## Best Practices

1.  **Keep it simple** - Focus on one concept
2.  **Make it runnable** - Avoid pseudo-code
3.  **Document well** - Context is crucial
4.  **Version agnostic** - Note version requirements
5.  **Error handling** - Show proper error patterns
6.  **Real-world ready** - Production-quality examples