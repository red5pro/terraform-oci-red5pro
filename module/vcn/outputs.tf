
output "red5pro_node_network_security_group" {
  description = "SSH private key path"
  value       = local.do_create_node_network ? oci_core_network_security_group.red5pro_node_network_security_group[0].display_name : ""
}

output "red5pro_node_network_security_group_id" {
  description = "SSH private key path"
  value       = local.do_create_node_network ? oci_core_network_security_group.red5pro_node_network_security_group[0].id : ""
}

output "subnet_id" {
  description = "Subnet id"
  value       = oci_core_subnet.red5pro_vcn_subnet_public.id
}

output "subnet_name" {
  description = "Subnet name"
  value       = oci_core_subnet.red5pro_vcn_subnet_public.display_name
}

output "vcn_id" {
  value = oci_core_vcn.red5pro_vcn.id
}

output "vcn_name" {
  value = oci_core_vcn.red5pro_vcn.display_name
}

output "vcn_cidr_block" {
  value = oci_core_vcn.red5pro_vcn.cidr_block
}


output "red5pro_standalone_network_security_group_id" {
  value = try(oci_core_network_security_group.red5pro_standalone_network_security_group[0].id, "")
}

output "red5pro_kafka_network_security_group_id" {
  value = try(oci_core_network_security_group.red5pro_kafka_network_security_group[0].id, "")
}

output "red5pro_stream_manager_network_security_group_id" {
  value = try(oci_core_network_security_group.red5pro_stream_manager_network_security_group[0].id, "")
}
