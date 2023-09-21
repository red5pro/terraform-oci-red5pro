locals {
  single                           = var.type == "single" ? true : false
  cluster                          = var.type == "cluster" ? true : false
  autoscaling                      = var.type == "autoscaling" ? true : false
  vcn_id                           = var.vcn_create ? oci_core_vcn.red5pro_vcn[0].id : var.vcn_id_existing
  vcn_name                         = var.vcn_create ? oci_core_vcn.red5pro_vcn[0].display_name : var.vcn_name_existing
  subnet_id                        = var.vcn_create ? oci_core_subnet.red5pro_vcn_subnet_public[0].id : var.subnet_id_existing
  subnet_name                      = var.vcn_create ? oci_core_subnet.red5pro_vcn_subnet_public[0].display_name : var.subnet_name_existing
  node_network_security_group_id   = var.network_security_group_create ? oci_core_network_security_group.red5pro_node_network_security_group[0].id : var.network_security_group_id_existing
  node_network_security_group_name = var.network_security_group_create ? oci_core_network_security_group.red5pro_node_network_security_group[0].display_name : var.network_security_group_name_existing
  enable_ipv6                      = false
  mysql_db_system_create           = local.autoscaling ? true : local.cluster && var.mysql_db_system_create ? true : local.cluster && var.dedicated_terra_host_create ? true : false
  mysql_host                       = local.autoscaling ? oci_mysql_mysql_db_system.red5pro_mysql_db_system[0].ip_address : local.cluster && var.mysql_db_system_create ? oci_mysql_mysql_db_system.red5pro_mysql_db_system[0].ip_address : local.cluster && var.dedicated_terra_host_create ? oci_mysql_mysql_db_system.red5pro_mysql_db_system[0].ip_address : "localhost"
  mysql_local_enable               = local.autoscaling ? false : var.mysql_db_system_create ? false : true
  dedicated_terra_host_create      = local.autoscaling ? true : local.cluster && var.dedicated_terra_host_create ? true : false
  terra_host                       = local.autoscaling ? oci_core_instance.red5pro_terraform_service[0].private_ip : local.cluster && var.dedicated_terra_host_create ? oci_core_instance.red5pro_terraform_service[0].private_ip : "localhost"
  terra_host_local_enable          = local.autoscaling ? false : var.dedicated_terra_host_create ? false : true
  oci_lb_cert_create               = local.autoscaling ? true : var.https_oci_certificates_use_existing ? false : true
  oci_lb_cert                      = local.autoscaling ? oci_load_balancer_certificate.red5pro_lb_ssl_cert[0].certificate_name : var.https_oci_certificates_certificate_name
  stream_manager_ip                = local.autoscaling && var.reserved_public_ip_address_create ? oci_core_public_ip.red5pro_reserved_ip[0].ip_address : local.cluster ? oci_core_instance.red5pro_sm[0].public_ip : var.reserved_public_ip_address_existing
}
