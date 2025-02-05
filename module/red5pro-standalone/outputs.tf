
output "standalone_red5pro_server_ip" {
  description = "Standalone Red5 Pro Server IP"
  value       = oci_core_instance.red5pro_standalone.public_ip
}
output "standalone_red5pro_server_http_url" {
  description = "Standalone Red5 Pro Server HTTP URL"
  value       = "http://${oci_core_instance.red5pro_standalone.public_ip}:5080"
}
output "standalone_red5pro_server_https_url" {
  description = "Standalone Red5 Pro Server HTTPS URL"
  value       = var.https_ssl_certificate != "none" ? "https://${var.https_ssl_certificate_domain_name}:443" : ""
}
output "manual_dns_record" {
  description = "Manual DNS Record"
  value       = var.https_ssl_certificate != "none" ? "Please create DNS A record for Red5pro server: '${var.https_ssl_certificate_domain_name} - ${oci_core_instance.red5pro_standalone.public_ip}'" : ""
}

