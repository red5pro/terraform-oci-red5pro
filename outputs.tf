################################################################################
# OUTPUTS
################################################################################

output "vcn_id" {
  description = "Oracle Cloud VCN ID"
  value       = local.vcn_id
}
output "vcn_name" {
  description = "Oracle Cloud VCN Name"
  value       = local.vcn_name
}
output "subnet_id" {
  description = "Oracle Cloud VCN Subnet ID"
  value       = local.subnet_id
}
output "subnet_name" {
  description = "Oracle Cloud VCN Subnet Name"
  value       = local.subnet_name
}
output "ssh_private_key_path" {
  description = "SSH private key path"
  value       = local.ssh_private_key_path
}
output "stream_manager_red5pro_node_network_security_group" {
  description = ""
  value       = try(module.vcn.red5pro_node_network_security_group, "")
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
output "stream_manager_red5pro_node_image" {
  description = "Stream Manager 2.0 Red5 Pro Node Image (OCI Custom Image)"
  value       = try(local.node_image_display_name, "")
}
output "standalone_red5pro_server_ip" {
  description = "Standalone Red5 Pro Server IP"
  value       = local.standalone ? oci_core_instance.red5pro_standalone[0].public_ip : ""
}
output "standalone_red5pro_server_http_url" {
  description = "Standalone Red5 Pro Server HTTP URL"
  value       = local.standalone ? "http://${oci_core_instance.red5pro_standalone[0].public_ip}:5080" : ""
}
output "standalone_red5pro_server_https_url" {
  description = "Standalone Red5 Pro Server HTTPS URL"
  value       = local.standalone && var.https_ssl_certificate != "none" ? "https://${var.https_ssl_certificate_domain_name}:443" : ""
}
output "manual_dns_record" {
  description = "Manual DNS Record"
  value       = var.https_ssl_certificate != "none" ? "Please create DNS A record for Stream Manager 2.0: '${var.https_ssl_certificate_domain_name} - ${local.cluster_or_autoscale ? local.stream_manager_ip : oci_core_instance.red5pro_standalone[0].public_ip}'" : ""
}
