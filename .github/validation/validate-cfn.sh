#!/bin/bash
# validate-cfn.sh - Complete template validation pipeline
set -euo pipefail

TEMPLATE="${1:?Usage: validate-cfn.sh TEMPLATE_FILE}"

echo "=== Step 1: YAML Syntax ==="
python3 -c "import yaml; yaml.safe_load(open('$TEMPLATE'))" && echo "PASS"

echo ""
echo "=== Step 2: cfn-lint ==="
cfn-lint "$TEMPLATE" && echo "PASS"

echo ""
echo "=== Step 3: CloudFormation validate-template ==="
aws cloudformation validate-template \
  --template-body "file://$TEMPLATE" > /dev/null && echo "PASS"

echo ""
echo "=== Step 4: cfn-guard (if rules exist) ==="
if [ -f "rules.guard" ]; then
  cfn-guard validate --data "$TEMPLATE" --rules rules.guard && echo "PASS"
else
  echo "SKIP - no rules.guard file found"
fi

echo ""
echo "All validation checks passed for $TEMPLATE"