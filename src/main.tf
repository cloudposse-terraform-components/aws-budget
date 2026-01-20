locals {
  enabled = module.this.enabled
}

module "budgets" {
  source  = "cloudposse/budgets/aws"
  version = "0.8.0"
  enabled = local.enabled

  budgets = var.budgets

  notifications_enabled = var.notifications_enabled

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = var.slack_channel
  slack_username    = var.slack_username

  context = module.this.context
}