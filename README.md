# AWS Firewall Manager Demo

This project demonstrates how to set up centralized WAF management with team-based access control using AWS Firewall Manager with cloudfront distribution.

> [!WARNING]  
> ## ⚠️ Important Disclaimer
>
> **This project is for testing and demonstration purposes only.**
>
>Please be aware of the following:
>
>- The infrastructure deployed by this project is not intended for production use.
>- Security measures may not be comprehensive or up to date.
>- Performance and reliability have not been thoroughly tested at scale.
>- The project may not comply with all best practices or organizational standards.
>
>Before using any part of this project in a production environment:
>
>1. Thoroughly review and understand all code and configurations.
>2. Conduct a comprehensive security audit.
>3. Test extensively in a safe, isolated environment.
>4. Adapt and modify the code to meet your specific requirements and security standards.
>5. Ensure compliance with your organization's policies and any relevant regulations.
>
>The maintainers of this project are not responsible for any issues that may arise from the use of this code in production environments.

---


## Resource Naming Strategy

All resources in this project use a unique naming strategy to avoid conflicts:

1. **Unique Suffix**: Each deployment generates a random suffix that is appended to resource names
2. **Team/Environment Prefixes**: Resources are prefixed with team and environment identifiers
3. **Consistent Format**: Resources follow the pattern `[team]-[resource-name]-[random-suffix]`

## Project Structure

- Root module: Contains the main Firewall Manager and WAF configurations

## Prerequisites

Before deploying this demo, you need to set up cross-account access manually:

### Cross-Account Access Setup

This demo requires three AWS accounts:
- **Security Account**: Acts as the Firewall Manager administrator
- **Dev Account**: Contains development resources (CloudFront distribution)
- **Prod Account**: Contains production resources (CloudFront distribution)

#### Step 1: Enable AWS Config in All Accounts

AWS Firewall Manager requires AWS Config to be enabled in all accounts:

1. In each account (security, dev, prod), go to the AWS Config console
2. Choose "Get started"
3. Configure AWS Config with default settings
4. Choose a bucket for configuration history
5. Enable recording

#### Step 2: Set Up Cross-Account Access

The demo uses the default `OrganizationAccountAccessRole` that AWS Organizations creates in member accounts:

1. Verify the role exists in both dev and prod accounts:
   ```bash
   # Check in dev account
   aws iam get-role --role-name OrganizationAccountAccessRole --profile dev
   
   # Check in prod account
   aws iam get-role --role-name OrganizationAccountAccessRole --profile prod
   ```

2. If the role doesn't exist, create it manually:
   ```bash
   # Create role in dev account (run with dev account credentials)
   aws iam create-role \
     --role-name OrganizationAccountAccessRole \
     --assume-role-policy-document '{
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "AWS": "arn:aws:iam::<SECURITY_ACCOUNT_ID>:root"
           },
           "Action": "sts:AssumeRole"
         }
       ]
     }'
   
   # Attach PowerUserAccess policy
   aws iam attach-role-policy \
     --role-name OrganizationAccountAccessRole \
     --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
   ```

3. If the role already exists but needs to be updated:
   ```bash
   # Update the trust policy to allow the security account to assume the role
   aws iam update-assume-role-policy \
     --role-name OrganizationAccountAccessRole \
     --policy-document '{
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "AWS": "arn:aws:iam::<SECURITY_ACCOUNT_ID>:root"
           },
           "Action": "sts:AssumeRole"
         }
       ]
     }' \
     --profile dev
   
   # Make sure the role has the necessary permissions
   aws iam attach-role-policy \
     --role-name OrganizationAccountAccessRole \
     --policy-arn arn:aws:iam::aws:policy/PowerUserAccess \
     --profile dev
   ```

4. Repeat the same steps for the prod account.

5. Verify the trust relationship is correctly set up:
   ```bash
   # From the security account, try to assume the role in the dev account
   aws sts assume-role \
     --role-arn arn:aws:iam::<DEV_ACCOUNT_ID>:role/OrganizationAccountAccessRole \
     --role-session-name test-session \
     --profile security
   
   # If successful, you'll receive temporary credentials
   ```

#### Step 3: Set Up Firewall Manager Admin

1. In the AWS Organizations management account, designate the security account as the Firewall Manager administrator:
   ```bash
   aws organizations enable-aws-service-access --service-principal fms.amazonaws.com
   aws fms associate-admin-account --admin-account <SECURITY_ACCOUNT_ID>
   ```

## Getting Started

1. Configure your AWS CLI with profiles for all three accounts:
   ```bash
   aws configure --profile security
   aws configure --profile dev
   aws configure --profile prod
   ```

2. Update the `terraform.tfvars` file with your account IDs:
   ```
   cp terraform.tfvars.example terraform.tfvars
   # Edit: security_account_id, dev_account_id, prod_account_id
   ```

3. Configure the S3 backend:
   ```
   cp config.s3.tfbackend.example config.s3.tfbackend
   # Edit: bucket name, region
   ```

4. Initialize and apply Terraform:
   ```bash
   terraform init -backend-config=config.s3.tfbackend
   terraform apply
   ```

## Troubleshooting Cross-Account Access

If you encounter permission issues when Terraform tries to assume roles:

1. Check if your current user has permission to assume the role:
   ```bash
   # Add your current user to the trust policy
   aws iam get-role --role-name OrganizationAccountAccessRole --profile dev
   
   # Update the trust policy to include your current user
   aws iam update-assume-role-policy \
     --role-name OrganizationAccountAccessRole \
     --policy-document '{
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "AWS": [
               "arn:aws:iam::<SECURITY_ACCOUNT_ID>:root",
               "arn:aws:iam::<YOUR_CURRENT_USER_ARN>"
             ]
           },
           "Action": "sts:AssumeRole"
         }
       ]
     }' \
     --profile dev
   ```

2. Verify the updated trust relationship works:
   ```bash
   aws sts assume-role \
     --role-arn arn:aws:iam::<DEV_ACCOUNT_ID>:role/OrganizationAccountAccessRole \
     --role-session-name test-session
   ```

## Testing the Demo

After deployment, you can test the demo by:

1. Checking the Firewall Manager policies:
   ```bash
   aws fms list-policies --region us-east-1 --profile security
   ```

2. Verifying WAF protection on CloudFront distributions:
   ```bash
   aws cloudfront get-distribution --id <DISTRIBUTION_ID> --profile dev
   ```

3. Testing team-based access by assuming the team roles:
   ```bash
   # Assume Team A role
   aws sts assume-role \
     --role-arn $(terraform output -raw team_a_role_arn) \
     --role-session-name team-a-test \
     --external-id team-a-external-id \
     --profile security
   ```

## Cleanup

To remove all resources created by this demo:

```bash
terraform destroy
```

## Architecture

This demo implements the following architecture:

```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│   Security Account  │    │    Dev Account      │    │   Prod Account      │
│                     │    │                     │    │                     │
│ • Firewall Manager  │    │ • CloudFront        │    │ • CloudFront        │
│ • WAF Rules         │    │ • S3 Bucket         │    │ • S3 Bucket         │
│ • Team IAM Roles    │    │ • Gets Team A WAF   │    │ • Gets Team B WAF   │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
```