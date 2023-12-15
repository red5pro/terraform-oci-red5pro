################################################################################
# OUTPUTS
################################################################################

output "node_origin_image" {
  description = "Oracle Cloud custom image name of the Red5 Pro Node Origin image"
  value       = try(oci_core_image.red5pro_node_origin_image[0].display_name, null)
}
output "node_edge_image" {
  description = "Oracle Cloud custom image name of the Red5 Pro Node Edge image"
  value       = try(oci_core_image.red5pro_node_edge_image[0].display_name, null)
}
output "node_transcoder_image" {
  description = "Oracle Cloud custom image name of the Red5 Pro Node Transcoder image"
  value       = try(oci_core_image.red5pro_node_transcoder_image[0].display_name, null)
}
output "node_relay_image" {
  description = "Oracle Cloud custom image name of the Red5 Pro Node Relay image"
  value       = try(oci_core_image.red5pro_node_relay_image[0].display_name, null)
}
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
output "ssh_private_key_path" {
  description = "SSH private key path"
  value       = var.ssh_private_key_path
}
output "mysql_db_system_create" {
  description = "Create MySQL DB System instance"
  value       = local.mysql_db_system_create
}
output "mysql_host" {
  description = "MySQL host"
  value       = local.mysql_host
}
output "stream_manager_ip" {
  description = "Stream Manager IP"
  value       = local.cluster ? local.stream_manager_ip : null
}
output "stream_manager_http_url" {
  description = "Stream Manager HTTP URL"
  value       = local.cluster ? "http://${local.stream_manager_ip}:5080" : null
}
output "stream_manager_https_url" {
  description = "Stream Manager HTTPS URL"
  value       = local.cluster ? var.https_letsencrypt_enable ? "https://${var.https_letsencrypt_certificate_domain_name}:443" : null : null
}
output "load_balancer_dns_name" {
  description = "Load Balancer DNS Name"
  value       = local.autoscaling ? local.stream_manager_ip : null
}
output "load_balancer_http_url" {
  description = "Load Balancer HTTP URL"
  value       = local.autoscaling ? "http://${local.stream_manager_ip}:5080" : null
}
output "load_balancer_https_url" {
  description = "Load Balancer HTTPS URL"
  value       = local.autoscaling ? var.https_oci_certificates_use_existing ? "https://${var.https_oci_certificates_certificate_name}:443" : null : null
}
output "single_red5pro_server_ip" {
  description = "Single Red5 Pro Server IP"
  value       = local.single ? oci_core_instance.red5pro_single[0].public_ip : null
}
output "single_red5pro_server_http_url" {
  description = "Single Red5 Pro Server HTTP URL"
  value       = local.single ? "http://${oci_core_instance.red5pro_single[0].public_ip}:5080" : null
}
output "single_red5pro_server_https_url" {
  description = "Single Red5 Pro Server HTTPS URL"
  value       = local.single && var.https_letsencrypt_enable ? "https://${var.https_letsencrypt_certificate_domain_name}:443" : null
}
