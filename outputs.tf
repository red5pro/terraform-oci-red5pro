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
  description = "SSH private key path"
  value       = local.cluster_or_autoscale || local.vcn ? oci_core_network_security_group.red5pro_node_network_security_group[0].display_name : ""
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
  description = "Stream Manager HTTPS URL (hostname from stream_manager_public_hostname, not https_ssl_certificate_domain_name — supports wildcard certs)"
  value       = local.cluster_or_autoscale ? var.https_ssl_certificate != "none" && var.stream_manager_public_hostname != ""  ? "https://${var.stream_manager_public_hostname}:443" : "" : ""
}
output "stream_manager_red5pro_node_image" {
  description = "Stream Manager 2.0 Red5 Pro Node Image (OCI Custom Image)"
  value       = try(oci_core_image.red5pro_node_image[0].display_name, "")
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
  description = "DNS hint for TLS: cluster/autoscale uses stream_manager_public_hostname; standalone uses https_ssl_certificate_domain_name"
  value = var.https_ssl_certificate != "none" ? (
    local.cluster_or_autoscale ? "Please create DNS A record for Stream Manager 2.0: '${var.stream_manager_public_hostname}' -> '${local.stream_manager_ip}'"
    : "Please create DNS A record for Standalone Red5 Pro: '${var.https_ssl_certificate_domain_name}' -> '${oci_core_instance.red5pro_standalone[0].public_ip}'"
  ) : ""
}

output "r5as_conference_secret" {
  description = "Auto-generated R5AS Conference secret (hex)"
  value       = try(random_id.r5as_conference_secret[0].hex, "")
}