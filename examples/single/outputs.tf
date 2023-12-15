output "vcn_id" {
  description = "Oracle Cloud VCN ID"
  value       = module.red5pro_single.vcn_id
}
output "vcn_name" {
  description = "Oracle Cloud VCN Name"
  value       = module.red5pro_single.vcn_name
}
output "ssh_private_key_path" {
  description = "SSH private key path"
  value       = module.red5pro_single.ssh_private_key_path
}
output "red5pro_server_ip" {
  description = "Red5 Pro Server IP"
  value       = module.red5pro_single.single_red5pro_server_ip
}
output "red5pro_server_http_url" {
  description = "Red5 Pro Server HTTP URL"
  value       = module.red5pro_single.single_red5pro_server_http_url
}
output "red5pro_server_https_url" {
  description = "Red5 Pro Server HTTPS URL"
  value       = module.red5pro_single.single_red5pro_server_https_url
}