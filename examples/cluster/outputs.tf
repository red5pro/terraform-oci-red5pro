
output "rabbitmq_private_ips" {
  description = "RabbitMQ instances private IPs"
  value       = module.red5pro.rabbitmq_private_ips
}
output "rabbitmq_public_ips" {
  description = "RabbitMQ instances public IPs"
  value       = module.red5pro.rabbitmq_public_ips
}
output "rabbitmq_user" {
  description = "RabbitMQ user name"
  value       = module.red5pro.rabbitmq_user
}
output "rabbitmq_password" {
  description = "RabbitMQ user password"
  value       = module.red5pro.rabbitmq_password
  sensitive   = true
}
output "stream_manager_intent_user" {
  description = "Stream Manager 2.0 intent API user name"
  value       = module.red5pro.stream_manager_intent_user
}
output "stream_manager_intent_password" {
  description = "Stream Manager 2.0 intent API user password"
  value       = module.red5pro.stream_manager_intent_password
  sensitive   = true
}
