output "budgets" {
  description = "List of AWS Budgets that were created"
  value       = module.budgets.budgets
}

output "sns_topic_arn" {
  description = "SNS topic ARN for budget notifications"
  value       = module.budgets.sns_topic_arn
}

output "lambda_function_arn" {
  description = "Lambda function ARN for Slack notifications"
  value       = module.budgets.lambda_function_arn
}