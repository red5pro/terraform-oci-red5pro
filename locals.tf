locals {
  single                           = var.type == "single" ? true : false
  cluster                          = var.type == "cluster" ? true : false
  autoscaling                      = var.type == "autoscaling" ? true : false
  cluster_or_autoscaling           = local.cluster || local.autoscaling ? true : false
  vcn_id                           = var.vcn_create ? oci_core_vcn.red5pro_vcn[0].id : var.vcn_id_existing
  vcn_name                         = var.vcn_create ? oci_core_vcn.red5pro_vcn[0].display_name : data.oci_core_vcn.red5pro_existing_vcn[0].display_name
  subnet_id                        = var.vcn_create ? oci_core_subnet.red5pro_vcn_subnet_public[0].id : var.subnet_id_existing
  subnet_name                      = var.vcn_create ? oci_core_subnet.red5pro_vcn_subnet_public[0].display_name : data.oci_core_subnet.red5pro_existing_subnet[0].display_name
  enable_ipv6                      = false
  mysql_db_system_create           = local.autoscaling ? true : local.cluster && var.mysql_db_system_create ? true : local.cluster && var.dedicated_terra_host_create ? true : false
  mysql_host                       = local.autoscaling ? oci_mysql_mysql_db_system.red5pro_mysql_db_system[0].ip_address : local.cluster && var.mysql_db_system_create ? oci_mysql_mysql_db_system.red5pro_mysql_db_system[0].ip_address : local.cluster && var.dedicated_terra_host_create ? oci_mysql_mysql_db_system.red5pro_mysql_db_system[0].ip_address : "localhost"
  mysql_local_enable               = local.autoscaling ? false : var.mysql_db_system_create ? false : true
  dedicated_terra_host_create      = local.autoscaling ? true : local.cluster && var.dedicated_terra_host_create ? true : false
  terra_host                       = local.autoscaling ? oci_core_instance.red5pro_terraform_service[0].private_ip : local.cluster && var.dedicated_terra_host_create ? oci_core_instance.red5pro_terraform_service[0].private_ip : "localhost"
  terra_host_local_enable          = local.autoscaling ? false : local.cluster && var.dedicated_terra_host_create ? true : false
  oci_lb_cert_create               = local.autoscaling ? true : var.https_oci_certificates_use_existing ? false : true
  oci_lb_cert                      = local.autoscaling ? oci_load_balancer_certificate.red5pro_lb_ssl_cert[0].certificate_name : var.https_oci_certificates_certificate_name
  stream_manager_ip                = local.autoscaling ? oci_core_public_ip.red5pro_reserved_ip[0].ip_address : local.cluster ? oci_core_instance.red5pro_sm[0].public_ip : null
  ssh_private_key_path             = var.ssh_key_create ? local_file.red5pro_ssh_key_pem[0].filename : var.ssh_private_key_path
  ssh_public_key_path              = var.ssh_key_create ? local_file.red5pro_ssh_key_pub[0].filename : var.ssh_public_key_path
}
