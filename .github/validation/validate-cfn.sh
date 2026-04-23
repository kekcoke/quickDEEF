#!/bin/bash

# validate-cfn.sh

set -euo pipefail

echo "Starting CloudFormation validation..."

# Allow argument override, fallback to default
TEMPLATE="${1:-templates/cloudformation.yml}"

#Check template exists
if [ ! -f "$TEMPLATE" ]; then
echo "Template not found: $TEMPLATE"
exit 1
fi

#Dependency checks
check_command() {
    if ! command -v "$1" &> /dev/null; then
    echo "$1 not found. Please install it."
    exit 1
    fi
}

check_command yamllint
check_command cfn-lint
check_command aws

# Optional dependency
HAS_CFN_GUARD=true
if ! command -v cfn-guard &> /dev/null; then
HAS_CFN_GUARD=false
fi

echo ""
echo "=== Step 1: YAML Lint (yamllint) ==="
yamllint -d '{extends: relaxed, rules: {line-length: disable}}' "$TEMPLATE"
echo "PASS"

echo ""
echo "=== Step 2: cfn-lint ==="
cfn-lint "$TEMPLATE"
echo "PASS"

echo ""
echo "=== Step 3: AWS validate-template ==="
aws cloudformation validate-template
--template-body "file://$TEMPLATE" > /dev/null
echo "PASS"

echo ""
echo "=== Step 4: cfn-guard (optional) ==="
if [ "$HAS_CFN_GUARD" = true ] && [ -f "rules.guard" ]; then
    cfn-guard validate --data "$TEMPLATE" --rules rules.guard
    echo "PASS"
else
    echo "SKIP - cfn-guard not installed or rules.guard not found"
fi

echo ""
echo "All validation checks passed for $TEMPLATE"