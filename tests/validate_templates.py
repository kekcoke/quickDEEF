import subprocess
import sys
import os

def run_command(command, description):
    print(f"--- Running {description} ---")
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"❌ {description} failed:")
        print(result.stdout)
        print(result.stderr)
        return False
    print(f"✅ {description} passed.")
    return True

def validate_cloudformation(file_path):
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return False

    # 1. Yamllint
    yaml_ok = run_command(f"yamllint -d '{{extends: relaxed, rules: {{line-length: disable}}}}' {file_path}", "yamllint")
    
    # 2. CFN-Lint
    cfn_ok = run_command(f"cfn-lint {file_path}", "cfn-lint")
    
    return yaml_ok and cfn_ok

if __name__ == "__main__":
    template_path = "templates/cloudformation.yml"
    success = validate_cloudformation(template_path)
    if not success:
        sys.exit(1)
