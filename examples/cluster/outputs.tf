output "vcn_id" {
  description = "Oracle Cloud VCN ID"
  value       = module.red5pro_cluster.vcn_id
}
output "vcn_name" {
  description = "Oracle Cloud VCN Name"
  value       = module.red5pro_cluster.vcn_name
}
output "ssh_private_key_path" {
  description = "SSH private key path"
  value       = module.red5pro_cluster.ssh_private_key_path
}
output "mysql_host" {
  description = "MySQL host"
  value       = module.red5pro_cluster.mysql_host
}
output "stream_manager_ip" {
  description = "Stream Manager IP"
  value       = module.red5pro_cluster.stream_manager_ip
}
output "stream_manager_http_url" {
  description = "Stream Manager HTTP URL"
  value       = module.red5pro_cluster.stream_manager_http_url
}
output "stream_manager_https_url" {
  description = "Stream Manager HTTPS URL"
  value       = module.red5pro_cluster.stream_manager_https_url
}
output "node_origin_image" {
  description = "Oracle Cloud custom image name of the Red5 Pro Node Origin image"
  value       = module.red5pro_cluster.node_origin_image
}