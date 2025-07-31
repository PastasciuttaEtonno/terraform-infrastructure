# Security Best Practices

## Overview
This Terraform configuration has been secured to prevent sensitive information from being exposed in the codebase.

## Security Improvements Made

### 1. Removed Hardcoded Secrets
- ❌ **Before**: Hardcoded secret values in variable defaults
- ✅ **After**: No default values for sensitive variables

### 2. Removed Hardcoded SSH Key Names
- ❌ **Before**: `key_name = "flask-app"` hardcoded in configuration
- ✅ **After**: `key_name = var.ssh_key_name` using variable reference

### 3. Added Sensitive Variable Marking
- All sensitive variables are marked with `sensitive = true`
- This prevents Terraform from displaying their values in logs

## Required Setup

### 1. Create terraform.tfvars file
```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit terraform.tfvars with your values
```hcl
# Replace with your actual SSH key name
ssh_key_name = "your-actual-key-name"

# Generate a strong secret (example using openssl):
# openssl rand -base64 32
cloudfront_secret_header_value = "your-generated-secret-here"
```

### 3. Ensure .gitignore is in place
The `.gitignore` file prevents sensitive files from being committed:
- `terraform.tfvars`
- `*.tfstate*`
- `.terraform/`

## Security Checklist

- [ ] SSH key exists in your AWS account
- [ ] `terraform.tfvars` file created with actual values
- [ ] Strong random secret generated for CloudFront header
- [ ] `.gitignore` file prevents committing sensitive files
- [ ] No hardcoded secrets in any `.tf` files

## Generating Secure Secrets

### For CloudFront Secret Header
```bash
# Generate a 32-character base64 encoded secret
openssl rand -base64 32

# Or generate a 64-character hex secret
openssl rand -hex 32
```

## Additional Security Recommendations

1. **Use AWS Secrets Manager** for application secrets
2. **Enable CloudTrail** for audit logging
3. **Use IAM roles** instead of access keys when possible
4. **Regularly rotate** SSH keys and secrets
5. **Enable MFA** on AWS accounts
6. **Use least privilege** IAM policies

## What NOT to do

❌ **Never commit these files:**
- `terraform.tfvars`
- `*.tfstate*`
- Any file containing actual passwords, keys, or secrets

❌ **Never hardcode:**
- Passwords
- API keys
- SSH key names
- Secret tokens
- Database credentials

✅ **Always use:**
- Variables for sensitive data
- `sensitive = true` for sensitive variables
- External secret management systems
- Environment variables or `.tfvars` files