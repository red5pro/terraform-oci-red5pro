################################################################################
# OUTPUTS
################################################################################

output "ssh_private_key_path" {
  description = "SSH private key path"
  value       = local.ssh_private_key_path
}
output "stream_manager_ip" {
  description = "Stream Manager 2.0 Public IP or Load Balancer Public IP"
  value       = local.cluster_or_autoscale ? local.stream_manager_ip : ""
}
output "stream_manager_url_http" {
  description = "Stream Manager HTTP URL"
  value       = local.cluster_or_autoscale ? "http://${local.stream_manager_ip}:80" : ""
}
output "stream_manager_url_https" {
  description = "Stream Manager HTTPS URL"
  value       = local.cluster_or_autoscale ? var.https_ssl_certificate != "none" ? "https://${var.https_ssl_certificate_domain_name}:443" : "" : ""
}
output "manual_dns_record" {
  description = "Manual DNS Record"
  value       = var.https_ssl_certificate != "none" ? "Please create DNS A record for Stream Manager 2.0: '${var.https_ssl_certificate_domain_name} - ${local.stream_manager_ip}'" : ""
}
