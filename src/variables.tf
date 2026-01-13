variable "region" {
  type        = string
  description = "AWS Region"
}

variable "budgets" {
  type        = any
  description = <<-EOF
  A list of Budgets to be managed by this module, see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget#argument-reference
  for a list of possible attributes. For a more specific example, see `https://github.com/cloudposse/terraform-aws-budgets/blob/master/examples/complete/fixtures.us-east-2.tfvars`.
  EOF
  default     = []
}

variable "notifications_enabled" {
  type        = bool
  description = "Whether or not to setup Slack notifications for Budgets. Set to `true` to create an SNS topic and Lambda function to send alerts to a Slack channel."
  default     = false
}

variable "slack_webhook_url" {
  type        = string
  description = "The URL of Slack webhook. Only used when `notifications_enabled` is `true`"
  default     = ""
  sensitive   = true
}

variable "slack_channel" {
  type        = string
  description = "The name of the channel in Slack for notifications. Only used when `notifications_enabled` is `true`"
  default     = ""
}

variable "slack_username" {
  type        = string
  description = "The username that will appear on Slack messages. Only used when `notifications_enabled` is `true`"
  default     = ""
}