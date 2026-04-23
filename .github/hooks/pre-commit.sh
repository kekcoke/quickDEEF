#!/bin/bash
# .git/hooks/pre-commit - Validate templates before commit

TEMPLATES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.yaml$|\.yml$|\.json$' | grep -i 'template\|cfn\|cloudformation')

if [ -z "$TEMPLATES" ]; then
  exit 0
fi

echo "Validating CloudFormation templates..."

for template in $TEMPLATES; do
  echo "  Checking: $template"
  cfn-lint "$template"
  if [ $? -ne 0 ]; then
    echo "cfn-lint failed for $template"
    exit 1
  fi
done

echo "All templates passed validation."