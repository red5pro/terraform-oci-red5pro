
output "stream_manager_intent_user" {
  description = "Stream Manager 2.0 intent API user name"
  value       = module.red5pro.stream_manager_intent_user
}
output "stream_manager_intent_password" {
  description = "Stream Manager 2.0 intent API user password"
  value       = module.red5pro.stream_manager_intent_password
  sensitive   = true
}
