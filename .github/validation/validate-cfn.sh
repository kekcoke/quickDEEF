#!/bin/bash
set -euo pipefail

# validate-cfn.sh - Reusable CloudFormation validation script
echo "🚀 Starting CloudFormation validation..."

# Allow argument override, fallback to default
TEMPLATE="${1:-templates/cloudformation.yml}"

if [ ! -f "$TEMPLATE" ]; then
    echo "❌ Template not found: $TEMPLATE"
    exit 1
fi

# Dependency checks
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "❌ $1 not found. Please install it."
        exit 1
    fi
}

check_command yamllint
check_command cfn-lint

# Optional cfn-guard check
HAS_CFN_GUARD=false
if command -v cfn-guard &> /dev/null; then
    HAS_CFN_GUARD=true
fi

echo "--- Step 1: YAML Lint ---"
yamllint -d '{extends: relaxed, rules: {line-length: disable}}' "$TEMPLATE"
echo "✅ PASS"

echo "--- Step 2: cfn-lint ---"
cfn-lint "$TEMPLATE"
echo "✅ PASS"

# Note: AWS CLI validation is skipped in CI unless credentials are provided.
# Commented out for local use if AWS CLI is configured.
# echo "--- Step 3: AWS validate-template ---"
# aws cloudformation validate-template --template-body "file://$TEMPLATE" > /dev/null
# echo "✅ PASS"

if [ "$HAS_CFN_GUARD" = true ] && [ -f "policies/rules.guard" ]; then
    echo "--- Step 4: cfn-guard ---"
    cfn-guard validate --data "$TEMPLATE" --rules policies/rules.guard
    echo "✅ PASS"
fi

echo "✨ All validation checks passed for $TEMPLATE"
