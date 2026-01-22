# Component: `aws-budgets`

This component is responsible for creating and managing AWS Budgets for cost monitoring and alerting.

The component supports:
- Multiple budget configurations (cost, usage, savings plans, etc.)
- Slack notifications via SNS + Lambda
- Encrypted SNS topics
- Flexible budget thresholds and time periods

## Usage

**Stack Level**: Global (deployed in each account where budget monitoring is needed)

### Catalog Configuration

First, add the abstract component to your catalog:

```yaml
components:
  terraform:
    # Abstract defaults - inherit from this in each account's stack
    aws-budget/defaults:
      metadata:
        component: aws-budget
        type: abstract
      vars:
        enabled: true
        name: aws-budget
        # Slack notifications are disabled by default
        notifications_enabled: false
        slack_webhook_url: ""
        slack_channel: ""
        slack_username: ""
        # Default budget configuration - $5000 monthly limit with CloudWatch alarm
        budgets:
          - name: "default"
            budget_type: "COST"
            limit_amount: "5000"
            limit_unit: "USD"
            time_unit: "MONTHLY"
            time_period_start: "YYYY-MM-DD_HH:MM"  # Set to your desired start date
            # CloudWatch alarm at 80% of budget threshold
            notifications:
              - comparison_operator: "GREATER_THAN"
                threshold: 80
                threshold_type: "PERCENTAGE"
                notification_type: "ACTUAL"
                # Uses default SNS topic created by the module
            # cost_filters:
            #   Service:
            #     - Amazon Elastic Compute Cloud - Compute
            #     - Amazon Simple Storage Service
            #     - Amazon Relational Database Service
            #     - AWS Lambda
            #     - Amazon CloudFront
```

### Stack Configuration

Then inherit from the defaults in your stack:

```yaml
components:
  terraform:
    aws-budget:
      metadata:
        inherits:
          - aws-budget/defaults
      vars:
        # Override defaults as needed
        budgets:
          - name: "monthly-cost-budget"
            budget_type: "COST"
            limit_amount: "100"
            limit_unit: "USD"
            time_unit: "MONTHLY"
            cost_filters:
              Service:
                - "Amazon Elastic Compute Cloud - Compute"
                - "Amazon Relational Database Service"
            notifications:
              - comparison_operator: "GREATER_THAN"
                threshold: 80
                threshold_type: "PERCENTAGE"
                notification_type: "ACTUAL"
              - comparison_operator: "GREATER_THAN"
                threshold: 100
                threshold_type: "PERCENTAGE" 
                notification_type: "FORECASTED"
        
        # Enable Slack notifications
        notifications_enabled: true
        slack_webhook_url: "https://hooks.slack.com/services/YOUR_SLACK_WEBHOOK_URL_HERE"
        slack_channel: "#aws-alerts"
        slack_username: "AWS Budgets"
```

## Variables

| Name | Description | Default | Sensitive |
|------|-------------|---------|:---------:|
| `budgets` | List of budget configurations | `[]` | No |
| `notifications_enabled` | Enable Slack notifications | `false` | No |
| `slack_webhook_url` | Slack webhook URL for notifications | `""` | Yes |
| `slack_channel` | Slack channel for notifications | `""` | No |
| `slack_username` | Username for Slack notifications | `""` | No |

## Budget Configuration

Each budget in the `budgets` list supports the following parameters (see [AWS Budgets Terraform documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) for complete reference):

| Parameter | Description | Required |
|-----------|-------------|:--------:|
| `name` | Budget name | Yes |
| `budget_type` | `COST`, `USAGE`, `RI_UTILIZATION`, `RI_COVERAGE`, `SAVINGS_PLANS_UTILIZATION`, `SAVINGS_PLANS_COVERAGE` | Yes |
| `limit_amount` | Budget limit amount | Yes |
| `limit_unit` | Budget limit unit (e.g., `USD`, `GB`) | Yes |
| `time_unit` | `DAILY`, `MONTHLY`, `QUARTERLY`, `ANNUALLY` | Yes |
| `time_period_start` | Budget start time in format "YYYY-MM-DD_HH:MM" (optional) | No |
| `time_period_end` | Budget end time (optional) | No |
| `cost_filters` | Cost filters (Service, AZ, etc.) | No |
| `notifications` | List of notification thresholds | No |

## Example Budget Configurations

### Monthly Cost Budget with Service Filtering
```yaml
budgets:
  - name: "ec2-monthly-budget"
    budget_type: "COST"
    limit_amount: "500"
    limit_unit: "USD" 
    time_unit: "MONTHLY"
    cost_filters:
      Service:
        - "Amazon Elastic Compute Cloud - Compute"
    notifications:
      - comparison_operator: "GREATER_THAN"
        threshold: 80
        threshold_type: "PERCENTAGE"
        notification_type: "ACTUAL"
      - comparison_operator: "GREATER_THAN"
        threshold: 100
        threshold_type: "PERCENTAGE"
        notification_type: "FORECASTED"
```

### Usage Budget for Data Transfer
```yaml
budgets:
  - name: "data-transfer-budget"
    budget_type: "USAGE"
    limit_amount: "1000"
    limit_unit: "GB"
    time_unit: "MONTHLY"
    cost_filters:
      Service:
        - "Amazon CloudFront"
    notifications:
      - comparison_operator: "GREATER_THAN"
        threshold: 90
        threshold_type: "PERCENTAGE"
        notification_type: "ACTUAL"
```

## Slack Notifications

When `notifications_enabled: true`, the component creates:
- An encrypted SNS topic for budget notifications
- A Lambda function that forwards SNS messages to Slack
- Proper IAM roles and permissions

**Required Variables for Slack:**
- `slack_webhook_url`: Your Slack webhook URL (marked as sensitive)
- `slack_channel`: Channel name (e.g., `#aws-alerts`)
- `slack_username`: Bot username (e.g., `AWS Budgets`)

## Security

- SNS topics are encrypted by default using KMS
- Slack webhook URL is marked as sensitive in Terraform state
- Lambda function uses least-privilege IAM permissions

## Outputs

| Name | Description |
|------|-------------|
| `budgets` | List of created AWS Budgets |
| `sns_topic_arn` | ARN of the SNS topic for notifications |
| `lambda_function_arn` | ARN of the Lambda function for Slack notifications |

## Migration from `account-settings`

If migrating from the legacy `account-settings` component:

1. Remove budget-related variables from `account-settings`
2. Deploy this `aws-budgets` component with equivalent configuration
3. Update variable names (remove `budgets_` prefix):
   - `budgets_notifications_enabled` → `notifications_enabled`
   - `budgets_slack_webhook_url` → `slack_webhook_url`
   - `budgets_slack_channel` → `slack_channel`
   - `budgets_slack_username` → `slack_username`

## References

- [AWS Budgets Documentation](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html)
- [Terraform AWS Budgets Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget)
- [CloudPosse AWS Budgets Module](https://github.com/cloudposse/terraform-aws-budgets)