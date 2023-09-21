output "vcn_id" {
  description = "Oracle Cloud VCN ID"
  value       = module.red5pro_stream_manager.vcn_id
}
output "vcn_name" {
  description = "Oracle Cloud VCN Name"
  value       = module.red5pro_stream_manager.vcn_name
}
output "ssh_key_name" {
  description = "SSH key name"
  value       = module.red5pro_stream_manager.ssh_key_name
}
output "ssh_private_key_path" {
  description = "SSH private key path"
  value       = module.red5pro_stream_manager.ssh_private_key_path
}
output "mysql_host" {
  description = "MySQL host"
  value       = module.red5pro_stream_manager.mysql_host
}
output "load_balancer_dns_name" {
  description = "Load Balancer DNS Name"
  value       = module.red5pro_stream_manager.load_balancer_dns_name
}
output "load_balancer_http_url" {
  description = "Load Balancer HTTP URL"
  value       = module.red5pro_stream_manager.load_balancer_http_url
}
output "load_balancer_https_url" {
  description = "Load Balancer HTTPS URL"
  value       = module.red5pro_stream_manager.load_balancer_https_url
}
output "node_origin_image" {
  description = "Oracle Cloud custom image name of the Red5 Pro Node Origin image"
  value       = module.red5pro_stream_manager.node_origin_image
}