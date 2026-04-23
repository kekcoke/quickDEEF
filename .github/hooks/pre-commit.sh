#!/bin/bash
# Pre-commit hook to validate CloudFormation templates
set -e

# Identify changed CloudFormation files
TEMPLATES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.yaml$|\.yml$' | grep -i 'templates/' || true)

if [ -z "$TEMPLATES" ]; then
    exit 0
fi

echo "🔍 Running validation on staged templates..."

for template in $TEMPLATES; do
    ./.github/validation/validate-cfn.sh "$template"
done

echo "✅ All staged templates passed validation."
