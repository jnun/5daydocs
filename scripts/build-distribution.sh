#!/bin/bash

# build-distribution.sh
# Installs templates into the current repo for dogfooding/testing

set -e

echo "🔨 Installing templates for dogfooding..."

# Install GitHub workflows from templates
echo "⚙️  Installing GitHub workflows..."
mkdir -p .github/workflows
cp templates/workflows/github/*.yml .github/workflows/
echo "✓ Installed workflows to .github/workflows/"

# Install GitHub issue and PR templates
echo "📋 Installing GitHub templates..."
mkdir -p .github/ISSUE_TEMPLATE
cp templates/github/ISSUE_TEMPLATE/*.md .github/ISSUE_TEMPLATE/
cp templates/github/pull_request_template.md .github/
echo "✓ Installed GitHub templates to .github/"

echo ""
echo "✅ Templates installed successfully!"
echo ""
echo "Installed files:"
echo "  - .github/workflows/sync-tasks-to-issues.yml"
echo "  - .github/ISSUE_TEMPLATE/*.md"
echo "  - .github/pull_request_template.md"
echo ""
echo "These files are now live for dogfooding/testing."
echo "Edit the source files in templates/ and re-run this script to update."
