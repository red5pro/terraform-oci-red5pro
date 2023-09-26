################################################################################
# MySQL Database (OCI MySQL DB System)
################################################################################
data "oci_mysql_mysql_versions" "default_mysql_versions" {
  compartment_id = var.compartment_id
}

data "oci_mysql_mysql_configurations" "default_mds_mysql_configurations" {
  compartment_id = var.compartment_id
  state          = "ACTIVE"
  shape_name     = var.mysql_shape_name
}

resource "oci_mysql_mysql_configuration" "red5pro_mds_mysql_configuration" {
  count                   = local.mysql_db_system_create ? 1 : 0
  compartment_id          = var.compartment_id
  shape_name              = var.mysql_shape_name
  display_name            = "${var.name}-mysql-cnf"
  parent_configuration_id = data.oci_mysql_mysql_configurations.default_mds_mysql_configurations.configurations[0].id
  variables {
    max_connections            = "100000"
    binlog_expire_logs_seconds = "7200"
  }
}

resource "oci_mysql_mysql_db_system" "red5pro_mysql_db_system" {
  count                   = local.mysql_db_system_create ? 1 : 0
  availability_domain     = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id          = var.compartment_id
  display_name            = "${var.name}-mysql-db"
  shape_name              = var.mysql_shape_name
  subnet_id               = local.subnet_id
  admin_username          = var.mysql_user_name
  admin_password          = var.mysql_password
  configuration_id        = oci_mysql_mysql_configuration.red5pro_mds_mysql_configuration[0].id
  data_storage_size_in_gb = var.mysql_db_system_data_storage_size_in_gb
  defined_tags            = var.defined_tags
  port                    = 3306
  mysql_version           = data.oci_mysql_mysql_versions.default_mysql_versions.versions[1].versions[4].version
}
