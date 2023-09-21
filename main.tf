################################################################################
# Oracle Cloud Infrastructure
################################################################################

# Get latest Canonical Ubuntu 20.04 image
data "oci_core_images" "red5pro_image" {
  compartment_id   = var.compartment_id
  operating_system = "Canonical Ubuntu"
  filter {
    name   = "display_name"
    values = ["^Canonical-Ubuntu-20.04-([\\.0-9-]+)$"]
    regex  = true
  }
}

# Get List of Oracle cloud availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

################################################################################
# Red5 Pro Single Server (OCI Instance)
################################################################################

resource "oci_core_instance" "red5pro_single" {
  count               = local.single ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.single_instance_type
  display_name        = "${var.name}-single-server"

  shape_config {
    ocpus         = var.single_instance_cpu
    memory_in_gbs = var.single_instance_memory
  }

  source_details {
    source_id   = data.oci_core_images.red5pro_image.images[0].id
    source_type = "image"
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_id
    nsg_ids          = [var.network_security_group_create ? oci_core_network_security_group.red5pro_single_network_security_group[0].id : var.network_security_group_id_existing]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
  preserve_boot_volume = false

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "sudo netfilter-persistent save",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.red5pro_round_trip_auth_endpoint_invalidate}'",
      "export SSL_ENABLE='${var.https_letsencrypt_enable}'",
      "export SSL_DOMAIN='${var.https_letsencrypt_certificate_domain_name}'",
      "export SSL_MAIL='${var.https_letsencrypt_certificate_email}'",
      "export SSL_PASSWORD='${var.https_letsencrypt_certificate_password}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "nohup sudo -E /home/ubuntu/red5pro-installer/r5p_ssl_check_install.sh >> /home/ubuntu/red5pro-installer/r5p_ssl_check_install.log &",
      "sleep 2"
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

################################################################################
# OCI Instance Terraform Service
################################################################################

resource "oci_core_instance" "red5pro_terraform_service" {
  count               = local.dedicated_terra_host_create ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E4.Flex"
  display_name        = "${var.name}-terraform-service"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 8
  }

  source_details {
    source_id   = data.oci_core_images.red5pro_image.images[0].id
    source_type = "image"
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_id
    nsg_ids          = [var.network_security_group_create ? oci_core_network_security_group.red5pro_terraform_service_network_security_group[0].id : var.network_security_group_id_existing]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
  preserve_boot_volume = false

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_terraform_service_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_terraform_service_build)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_private_key_terraform_service
    destination = "/home/ubuntu/${basename(var.path_to_private_key_terraform_service)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_public_key_terraform_service
    destination = "/home/ubuntu/${basename(var.path_to_public_key_terraform_service)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }


  provisioner "remote-exec" {
    inline = [
      "sudo iptables -F",
      "sudo netfilter-persistent save",
      "sudo cloud-init status --wait",
      "export TENANCY_OCID='${var.tenancy_ocid}'",
      "export USER_OCID='${var.user_ocid}'",
      "export COMPARTMENT_ID='${var.compartment_id}'",
      "export FINGERPRINT='${var.fingerprint}'",
      "export PRIVATE_KEY_PATH='/home/ubuntu/${basename(var.path_to_private_key_terraform_service)}'",
      "export PUBLIC_KEY_PATH='/home/ubuntu/${basename(var.path_to_public_key_terraform_service)}'",
      "export REGION='${var.region}'",
      "export SUBNET_NAME='${local.subnet_name}'",
      "export NETWORK_SECURITY_GROUP='${local.node_network_security_group_name}'",
      "export DB_HOST='${local.mysql_host}'",
      "export DB_PORT='${var.mysql_port}'",
      "export DB_USER='${var.mysql_user_name}'",
      "export DB_PASSWORD='${var.mysql_password}'",
      "export TERRA_HOST='${self.private_ip}'",
      "export TERRA_API_TOKEN='${var.terra_api_token}'",
      "export TERRA_PARALLELISM='${var.terra_parallelism}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*",
      "sudo chmod 400 /home/ubuntu/${basename(var.path_to_private_key_terraform_service)}",
      "sudo chmod 400 /home/ubuntu/${basename(var.path_to_public_key_terraform_service)}",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_terraform_svc.sh",
      "sleep 2"
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

################################################################################
# Red5 Pro Stream Manager - (OCI Instance)
################################################################################

resource "oci_core_instance" "red5pro_sm" {
  count               = local.cluster || local.autoscaling ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.stream_manager_instance_type
  display_name        = "${var.name}-stream-manager"

  shape_config {
    ocpus         = var.stream_manager_instance_cpu
    memory_in_gbs = var.stream_manager_instance_memory
  }

  source_details {
    source_id   = data.oci_core_images.red5pro_image.images[0].id
    source_type = "image"
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_id
    nsg_ids          = [var.network_security_group_create ? oci_core_network_security_group.red5pro_stream_manager_network_security_group[0].id : var.network_security_group_id_existing]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
  preserve_boot_volume = false

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_terraform_cloud_controller
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_terraform_cloud_controller)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_terraform_service_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_terraform_service_build)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_private_key_terraform_service
    destination = "/home/ubuntu/${basename(var.path_to_private_key_terraform_service)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_public_key_terraform_service
    destination = "/home/ubuntu/${basename(var.path_to_public_key_terraform_service)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "sudo netfilter-persistent save",
      "export TENANCY_OCID='${var.tenancy_ocid}'",
      "export USER_OCID='${var.user_ocid}'",
      "export COMPARTMENT_ID='${var.compartment_id}'",
      "export FINGERPRINT='${var.fingerprint}'",
      "export PRIVATE_KEY_PATH='/home/ubuntu/${basename(var.path_to_private_key_terraform_service)}'",
      "export PUBLIC_KEY_PATH='/home/ubuntu/${basename(var.path_to_public_key_terraform_service)}'",
      "export REGION='${var.region}'",
      "export SUBNET_NAME='${local.subnet_name}'",
      "export NETWORK_SECURITY_GROUP='${local.node_network_security_group_name}'",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export SM_API_KEY='${var.stream_manager_api_key}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_CLUSTER_KEY='${var.red5pro_cluster_key}'",
      "export NODE_PREFIX_NAME='${var.name}-node'",
      "export DB_LOCAL_ENABLE='${local.mysql_local_enable}'",
      "export TF_SVC_LOCAL_ENABLE='${local.terra_host_local_enable}'",
      "export DB_HOST='${local.mysql_host}'",
      "export DB_PORT='${var.mysql_port}'",
      "export DB_USER='${var.mysql_user_name}'",
      "export DB_PASSWORD='${var.mysql_password}'",
      "export SSL_ENABLE='${var.https_letsencrypt_enable}'",
      "export SSL_DOMAIN='${var.https_letsencrypt_certificate_domain_name}'",
      "export SSL_MAIL='${var.https_letsencrypt_certificate_email}'",
      "export SSL_PASSWORD='${var.https_letsencrypt_certificate_password}'",
      "export TERRA_HOST='${local.terra_host}'",
      "export TERRA_API_TOKEN='${var.terra_api_token}'",
      "export TERRA_PARALLELISM='${var.terra_parallelism}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_mysql_local.sh",
      "sudo chmod 400 /home/ubuntu/${basename(var.path_to_private_key_terraform_service)}",
      "sudo chmod 400 /home/ubuntu/${basename(var.path_to_public_key_terraform_service)}",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_terraform_svc_local.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_stream_manager.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "nohup sudo -E /home/ubuntu/red5pro-installer/r5p_ssl_check_install.sh >> /home/ubuntu/red5pro-installer/r5p_ssl_check_install.log &",
      "sleep 2"
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

################################################################################
# Red5 Pro Stream Manager Autoscaling (OCI Load Balancer + Autoscaling)
################################################################################
# SM Load Balancer
data "oci_core_public_ip" "red5pro_reserved_ip_by_ip" {
  count      = local.autoscaling && var.reserved_public_ip_address_create ? 0 : 1
  ip_address = var.reserved_public_ip_address_existing
}

resource "oci_core_public_ip" "red5pro_reserved_ip" {
  count          = local.autoscaling && var.reserved_public_ip_address_create ? 1 : 0
  compartment_id = var.compartment_id
  lifetime       = "RESERVED"

  lifecycle {
    ignore_changes = [private_ip_id]
  }
}

resource "oci_load_balancer_load_balancer" "red5pro_lb" {
  count                      = local.autoscaling ? 1 : 0
  display_name               = "${var.name}-lb"
  compartment_id             = var.compartment_id
  network_security_group_ids = []
  shape                      = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = 100
    minimum_bandwidth_in_mbps = 10
  }

  subnet_ids = [local.subnet_id]

  reserved_ips {
    id = local.autoscaling && var.reserved_public_ip_address_create ? oci_core_public_ip.red5pro_reserved_ip[0].id : data.oci_core_public_ip.red5pro_reserved_ip_by_ip[0].id
  }
}

resource "oci_load_balancer_backend_set" "red5pro_lb_backend_set" {
  count            = local.autoscaling ? 1 : 0
  name             = "${var.name}-lb-set"
  load_balancer_id = oci_load_balancer_load_balancer.red5pro_lb[0].id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "5080"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource "oci_load_balancer_listener" "red5pro_lb_listener_5080" {
  count                    = local.autoscaling ? 1 : 0
  load_balancer_id         = oci_load_balancer_load_balancer.red5pro_lb[0].id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.red5pro_lb_backend_set[0].name
  port                     = 5080
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

resource "oci_load_balancer_listener" "red5pro_lb_listener_443" {
  count                    = local.autoscaling ? 1 : 0
  load_balancer_id         = oci_load_balancer_load_balancer.red5pro_lb[0].id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.red5pro_lb_backend_set[0].name
  port                     = 443
  protocol                 = "HTTP"

  ssl_configuration {
    certificate_name        = local.oci_lb_cert
    verify_peer_certificate = false
    protocols               = ["TLSv1.1", "TLSv1.2"]
    server_order_preference = "ENABLED"
  }
}

# OCI SSL certificate

resource "oci_load_balancer_certificate" "red5pro_lb_ssl_cert" {
  count              = local.oci_lb_cert_create && local.autoscaling ? 1 : 0
  load_balancer_id   = oci_load_balancer_load_balancer.red5pro_lb[0].id
  ca_certificate     = file(var.cert_fullchain)
  certificate_name   = var.https_oci_certificates_certificate_name
  private_key        = file(var.cert_private_key)
  public_certificate = file(var.cert_public_cert)

  lifecycle {
    create_before_destroy = true
  }
}

# SM AUTOSCALING

resource "oci_core_image" "red5pro_sm_image" {
  count          = local.autoscaling ? 1 : 0
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.red5pro_sm[0].id

  display_name = "${var.name}-stream-manager"

  depends_on = [oci_core_instance.red5pro_sm]
}

resource "oci_core_instance_configuration" "red5pro_instance_configuration" {
  count          = local.autoscaling ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.name}-sm-instance-cnf"

  instance_details {
    instance_type = "compute"

    launch_details {
      display_name   = "${var.name}-sm-instance-ld"
      compartment_id = var.compartment_id
      shape          = var.stream_manager_instance_type

      create_vnic_details {
        subnet_id        = local.subnet_id
        display_name     = "${var.name}-sm-instance-vnic"
        assign_public_ip = true
        nsg_ids          = [var.network_security_group_create ? oci_core_network_security_group.red5pro_stream_manager_network_security_group[0].id : var.network_security_group_id_existing]
      }

      shape_config {
        ocpus         = var.stream_manager_instance_cpu
        memory_in_gbs = var.stream_manager_instance_memory
      }

      source_details {
        source_type = "image"
        image_id    = oci_core_image.red5pro_sm_image[0].id
      }

      metadata = {
        ssh_authorized_keys = file(var.ssh_public_key_path)
      }
    }
  }
}

resource "oci_core_instance_pool" "red5pro_instance_pool" {
  count                     = local.autoscaling ? 1 : 0
  compartment_id            = var.compartment_id
  instance_configuration_id = oci_core_instance_configuration.red5pro_instance_configuration[0].id
  size                      = 1
  state                     = "RUNNING"
  display_name              = "${var.name}-red5pro-sm"

  placement_configurations {
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    primary_subnet_id   = local.subnet_id
  }

  load_balancers {
    backend_set_name = oci_load_balancer_backend_set.red5pro_lb_backend_set[0].name
    load_balancer_id = oci_load_balancer_load_balancer.red5pro_lb[0].id
    port             = 5080
    vnic_selection   = "primaryvnic"
  }
}

resource "oci_autoscaling_auto_scaling_configuration" "red5pro_autoscaling_configuration" {
  count                = local.autoscaling ? 1 : 0
  compartment_id       = var.compartment_id
  cool_down_in_seconds = "300"
  display_name         = "${var.name}-autoscale-cnf"
  is_enabled           = "true"

  policies {
    capacity {
      initial = "1"
      max     = "2"
      min     = "1"
    }

    display_name = "${var.name}-autoscale-policy"
    policy_type  = "threshold"

    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = "1"
      }

      display_name = "${var.name}-autoscale-out-rule"

      metric {
        metric_type = "CPU_UTILIZATION"

        threshold {
          operator = "GT"
          value    = "80"
        }
      }
    }

    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = "-1"
      }

      display_name = "${var.name}-autoscale-in-rule"

      metric {
        metric_type = "CPU_UTILIZATION"

        threshold {
          operator = "LT"
          value    = "1"
        }
      }
    }
  }

  auto_scaling_resources {
    id   = oci_core_instance_pool.red5pro_instance_pool[0].id
    type = "instancePool"
  }
}

################################################################################
# Red5 Pro Autoscaling Nodes - Origin/Edge/Transcoders/Relay (OCI Instance)
################################################################################

# Origin Node instance for OCI Custom Image
resource "oci_core_instance" "red5pro_node_origin" {
  count               = var.origin_image_create ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.origin_image_instance_type
  display_name        = "${var.name}-node-origin-image"

  shape_config {
    ocpus         = var.origin_image_instance_cpu
    memory_in_gbs = var.origin_image_instance_memory
  }

  source_details {
    source_id   = data.oci_core_images.red5pro_image.images[0].id
    source_type = "image"
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_id
    nsg_ids          = [var.network_security_group_create ? oci_core_network_security_group.red5pro_node_network_security_group[0].id : var.network_security_group_id_existing]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
  preserve_boot_volume = false

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "sudo netfilter-persistent save",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export SM_IP='${local.stream_manager_ip}'",
      "export NODE_CLUSTER_KEY='${var.red5pro_cluster_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.origin_image_red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.origin_image_red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.origin_image_red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.origin_image_red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.origin_image_red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.origin_image_red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.origin_image_red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.origin_image_red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.origin_image_red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.origin_image_red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.origin_image_red5pro_round_trip_auth_endpoint_invalidate}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "sleep 2"
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

# Edge Node instance for OCI Custom Image
resource "oci_core_instance" "red5pro_node_edge" {
  count               = var.edge_image_create ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.edge_image_instance_type
  display_name        = "${var.name}-node-edge-image"

  shape_config {
    ocpus         = var.edge_image_instance_cpu
    memory_in_gbs = var.edge_image_instance_memory
  }

  source_details {
    source_id   = data.oci_core_images.red5pro_image.images[0].id
    source_type = "image"
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_id
    nsg_ids          = [var.network_security_group_create ? oci_core_network_security_group.red5pro_node_network_security_group[0].id : var.network_security_group_id_existing]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
  preserve_boot_volume = false

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "sudo netfilter-persistent save",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export SM_IP='${local.stream_manager_ip}'",
      "export NODE_CLUSTER_KEY='${var.red5pro_cluster_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.edge_image_red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.edge_image_red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.edge_image_red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.edge_image_red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.edge_image_red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.edge_image_red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.edge_image_red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.edge_image_red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.edge_image_red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.edge_image_red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.edge_image_red5pro_round_trip_auth_endpoint_invalidate}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "sleep 2"
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

# Transcoder Node instance for OCI Custom Image
resource "oci_core_instance" "red5pro_node_transcoder" {
  count               = var.transcoder_image_create ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.transcoder_image_instance_type
  display_name        = "${var.name}-node-transcoder-image"

  shape_config {
    ocpus         = var.transcoder_image_instance_cpu
    memory_in_gbs = var.transcoder_image_instance_memory
  }

  source_details {
    source_id   = data.oci_core_images.red5pro_image.images[0].id
    source_type = "image"
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_id
    nsg_ids          = [var.network_security_group_create ? oci_core_network_security_group.red5pro_node_network_security_group[0].id : var.network_security_group_id_existing]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
  preserve_boot_volume = false

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "sudo netfilter-persistent save",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export SM_IP='${local.stream_manager_ip}'",
      "export NODE_CLUSTER_KEY='${var.red5pro_cluster_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.transcoder_image_red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.transcoder_image_red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.transcoder_image_red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.transcoder_image_red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.transcoder_image_red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.transcoder_image_red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.transcoder_image_red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.transcoder_image_red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.transcoder_image_red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.transcoder_image_red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.transcoder_image_red5pro_round_trip_auth_endpoint_invalidate}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "sleep 2"
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

# Relay Node instance for OCI Custom Image
resource "oci_core_instance" "red5pro_node_relay" {
  count               = var.relay_image_create ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.relay_image_instance_type
  display_name        = "${var.name}-node-relay-image"

  shape_config {
    ocpus         = var.relay_image_instance_cpu
    memory_in_gbs = var.relay_image_instance_memory
  }

  source_details {
    source_id   = data.oci_core_images.red5pro_image.images[0].id
    source_type = "image"
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_id
    nsg_ids          = [var.network_security_group_create ? oci_core_network_security_group.red5pro_node_network_security_group[0].id : var.network_security_group_id_existing]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
  preserve_boot_volume = false

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo iptables -F",
      "sudo netfilter-persistent save",
      "export LICENSE_KEY='${var.red5pro_license_key}'",
      "export SM_IP='${local.stream_manager_ip}'",
      "export NODE_CLUSTER_KEY='${var.red5pro_cluster_key}'",
      "export NODE_API_ENABLE='${var.red5pro_api_enable}'",
      "export NODE_API_KEY='${var.red5pro_api_key}'",
      "export NODE_INSPECTOR_ENABLE='${var.relay_image_red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.relay_image_red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.relay_image_red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.relay_image_red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.relay_image_red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.relay_image_red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.relay_image_red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.relay_image_red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.relay_image_red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.relay_image_red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.relay_image_red5pro_round_trip_auth_endpoint_invalidate}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "sleep 2"
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

####################################################################################################
# Red5 Pro Autoscaling Nodes create images - Origin/Edge/Transcoders/Relay (OCI Custom Images)
####################################################################################################

# Origin node - Create image (OCI Custom Images)
resource "oci_core_image" "red5pro_node_origin_image" {
  count          = var.origin_image_create ? 1 : 0
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.red5pro_node_origin[0].id
  display_name   = "${var.name}-node-origin-image-${formatdate("DDMMMYY-hhmm", timestamp())}"
  depends_on     = [oci_core_instance.red5pro_node_origin]
}

# Edger node - Create image (OCI Custom Images)
resource "oci_core_image" "red5pro_node_edge_image" {
  count          = var.edge_image_create ? 1 : 0
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.red5pro_node_edge[0].id
  display_name   = "${var.name}-node-edge-image-${formatdate("DDMMMYY-hhmm", timestamp())}"
  depends_on     = [oci_core_instance.red5pro_node_edge]
}

# Transcoder node - Create image (OCI Custom Images)
resource "oci_core_image" "red5pro_node_transcoder_image" {
  count          = var.transcoder_image_create ? 1 : 0
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.red5pro_node_transcoder[0].id
  display_name   = "${var.name}-node-transcoder-image-${formatdate("DDMMMYY-hhmm", timestamp())}"
  depends_on     = [oci_core_instance.red5pro_node_transcoder]
}

# Relay node - Create image (OCI Custom Images)
resource "oci_core_image" "red5pro_node_relay_image" {
  count          = var.relay_image_create ? 1 : 0
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.red5pro_node_relay[0].id
  display_name   = "${var.name}-node-relay-image-${formatdate("DDMMMYY-hhmm", timestamp())}"
  depends_on     = [oci_core_instance.red5pro_node_relay]
}

################################################################################
# Stop instances which used for creating OCI custom images (OCI CLI)
################################################################################
# Stream Manager autoscaling - Stop Stream Manager instance using OCI CLI
resource "null_resource" "stop_stream_manager" {
  count = local.autoscaling ? 1 : 0
  provisioner "local-exec" {
    command = "oci compute instance action --action STOP --instance-id ${oci_core_instance.red5pro_sm[0].id}"
  }
  depends_on = [oci_core_image.red5pro_sm_image[0]]
}

# Stop Origin Node instance using OCI CLI
resource "null_resource" "stop_node_origin" {
  count = var.origin_image_create ? 1 : 0
  provisioner "local-exec" {
    command = "oci compute instance action --action STOP --instance-id ${oci_core_instance.red5pro_node_origin[0].id}"
  }
  depends_on = [oci_core_image.red5pro_node_origin_image[0]]
}
# Stop Edge Node instance using OCI CLI
resource "null_resource" "stop_node_edge" {
  count = var.edge_image_create ? 1 : 0
  provisioner "local-exec" {
    command = "oci compute instance action --action STOP --instance-id ${oci_core_instance.red5pro_node_edge[0].id}"
  }
  depends_on = [oci_core_image.red5pro_node_edge_image[0]]
}
# Stop Transcoder Node instance using OCI CLI
resource "null_resource" "stop_node_transcoder" {
  count = var.transcoder_image_create ? 1 : 0
  provisioner "local-exec" {
    command = "oci compute instance action --action STOP --instance-id ${oci_core_instance.red5pro_node_transcoder[0].id}"
  }
  depends_on = [oci_core_image.red5pro_node_transcoder_image[0]]
}
# Stop Relay Node instance using OCI CLI
resource "null_resource" "stop_node_relay" {
  count = var.relay_image_create ? 1 : 0
  provisioner "local-exec" {
    command = "oci compute instance action --action STOP --instance-id ${oci_core_instance.red5pro_node_relay[0].id}"
  }
  depends_on = [oci_core_image.red5pro_node_relay_image[0]]
}

################################################################################
# Create node group (Stream Manager API)
################################################################################

resource "null_resource" "node_group" {
  count = var.node_group_create ? 1 : 0
  triggers = {
    trigger_name = "node-group-trigger"
    SM_IP        = "${local.stream_manager_ip}"
    SM_API_KEY   = "${var.stream_manager_api_key}"
  }
  provisioner "local-exec" {
    when    = create
    command = "bash ${abspath(path.module)}/red5pro-installer/r5p_create_node_group.sh"
    environment = {
      NAME                     = "${var.name}"
      SM_IP                    = "${local.stream_manager_ip}"
      SM_API_KEY               = "${var.stream_manager_api_key}"
      NODE_GROUP_REGION        = "${var.region}"
      NODE_GROUP_NAME          = "${var.node_group_name}"
      ORIGINS                  = "${var.node_group_origins}"
      EDGES                    = "${var.node_group_edges}"
      TRANSCODERS              = "${var.node_group_transcoders}"
      RELAYS                   = "${var.node_group_relays}"
      ORIGIN_INSTANCE_TYPE     = "${var.node_group_origins_instance_type}"
      EDGE_INSTANCE_TYPE       = "${var.node_group_edges_instance_type}"
      TRANSCODER_INSTANCE_TYPE = "${var.node_group_transcoders_instance_type}"
      RELAY_INSTANCE_TYPE      = "${var.node_group_relays_instance_type}"
      ORIGIN_CAPACITY          = "${var.node_group_origins_capacity}"
      EDGE_CAPACITY            = "${var.node_group_edges_capacity}"
      TRANSCODER_CAPACITY      = "${var.node_group_transcoders_capacity}"
      RELAY_CAPACITY           = "${var.node_group_relays_capacity}"
      ORIGIN_IMAGE_NAME        = "${try(oci_core_image.red5pro_node_origin_image[0].display_name, null)}"
      EDGE_IMAGE_NAME          = "${try(oci_core_image.red5pro_node_edge_image[0].display_name, null)}"
      TRANSCODER_IMAGE_NAME    = "${try(oci_core_image.red5pro_node_transcoder_image[0].display_name, null)}"
      RELAY_IMAGE_NAME         = "${try(oci_core_image.red5pro_node_relay_image[0].display_name, null)}"
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "bash ${abspath(path.module)}/red5pro-installer/r5p_delete_node_group.sh '${self.triggers.SM_IP}' '${self.triggers.SM_API_KEY}'"
  }

  depends_on = [oci_core_instance.red5pro_sm[0], oci_load_balancer_load_balancer.red5pro_lb[0]]
}