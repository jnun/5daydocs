# Technical Guides

This directory contains technical documentation, how-to guides, and procedures for working with the project.

## Purpose

While `/features/` documents WHAT the product does, `/guides/` documents HOW to work with it:
- Development setup and workflows
- Operational procedures
- Troubleshooting steps
- Best practices and conventions
- API references and integration guides

## Guide Categories

### Setup & Installation
- Environment configuration
- Dependency management
- Initial project setup

### Development
- Coding standards and conventions
- Testing procedures
- Debugging techniques
- Performance optimization

### Operations
- Deployment processes
- Monitoring and logging
- Backup and recovery
- Security procedures

### Integration
- API documentation
- Third-party service integration
- Data import/export procedures

## File Naming Convention

Guide files use kebab-case naming: `guide-topic.md`

Examples:
- `development-setup.md`
- `api-authentication.md`
- `database-migrations.md`
- `troubleshooting-errors.md`

## Guide Document Template

```markdown
# Guide Title

## Purpose
What this guide helps you accomplish.

## Prerequisites
- Required tools or access
- Prior knowledge needed
- Related guides to read first

## Steps
1. Detailed step-by-step instructions
2. Include commands, code examples
3. Explain what each step does

## Verification
How to confirm the process worked correctly.

## Troubleshooting
Common issues and their solutions.

## Related Documentation
- Links to relevant features in /features/
- External documentation references
```

## Creating New Guides

Create a guide when:
- A process needs to be repeated by multiple people
- Complex procedures need documentation
- Common questions arise repeatedly
- Integration with external systems is required

Keep guides:
- **Focused** - One topic per guide
- **Practical** - Include real examples
- **Maintainable** - Update when processes change
- **Searchable** - Use clear, descriptive titles