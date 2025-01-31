locals {
  standalone                                       = var.type == "standalone" ? true : false
  cluster                                          = var.type == "cluster" ? true : false
  autoscale                                        = var.type == "autoscale" ? true : false
  cluster_or_autoscale                             = local.cluster || local.autoscale ? true : false
  vcn_id                                           = module.vcn.vcn_id
  vcn_name                                         = module.vcn.vcn_name
  vcn_cidr_block                                   = module.vcn.vcn_cidr_block
  subnet_id                                        = module.vcn.subnet_id
  subnet_name                                      = module.vcn.subnet_name
  stream_manager_ip                                = local.autoscale ? var.load_balancer_reserved_ip_use_existing ? data.oci_core_public_ip.red5pro_reserved_ip[0].ip_address : oci_core_public_ip.red5pro_reserved_ip[0].ip_address : local.cluster ? oci_core_instance.red5pro_sm[0].public_ip : "null"
  ssh_private_key_path                             = var.ssh_key_use_existing ? var.ssh_key_existing_private_key_path : local_file.red5pro_ssh_key_pem[0].filename
  ssh_public_key_path                              = var.ssh_key_use_existing ? var.ssh_key_existing_public_key_path : local_file.red5pro_ssh_key_pub[0].filename
  ssh_private_key                                  = var.ssh_key_use_existing ? file(var.ssh_key_existing_private_key_path) : tls_private_key.red5pro_ssh_key[0].private_key_pem
  ssh_public_key                                   = var.ssh_key_use_existing ? file(var.ssh_key_existing_public_key_path) : tls_private_key.red5pro_ssh_key[0].public_key_openssh
  load_balancer_reserved_ip_id                     = local.autoscale ? var.load_balancer_reserved_ip_use_existing ? data.oci_core_public_ip.red5pro_reserved_ip[0].id : oci_core_public_ip.red5pro_reserved_ip[0].id : null
  kafka_standalone_instance                        = local.autoscale ? true : local.cluster && var.kafka_standalone_instance_create ? true : false
  kafka_ip                                         = local.cluster_or_autoscale ? (var.kafka_public_ip ? (local.kafka_standalone_instance ? oci_core_instance.red5pro_kafka[0].public_ip : oci_core_instance.red5pro_sm[0].public_ip) : (local.kafka_standalone_instance ? oci_core_instance.red5pro_kafka[0].private_ip : oci_core_instance.red5pro_sm[0].private_ip)) : "null"
  kafka_on_sm_replicas                             = local.kafka_standalone_instance ? 0 : 1
  kafka_ssl_keystore_key                           = local.cluster_or_autoscale ? nonsensitive(join("\\\\n", split("\n", trimspace(tls_private_key.kafka_server_key[0].private_key_pem_pkcs8)))) : "null"
  kafka_ssl_truststore_cert                        = local.cluster_or_autoscale ? nonsensitive(join("\\\\n", split("\n", tls_self_signed_cert.ca_cert[0].cert_pem))) : "null"
  kafka_ssl_keystore_cert_chain                    = local.cluster_or_autoscale ? nonsensitive(join("\\\\n", split("\n", tls_locally_signed_cert.kafka_server_cert[0].cert_pem))) : "null"
  stream_manager_ssl                               = local.autoscale ? "none" : var.https_ssl_certificate
  stream_manager_standalone                        = local.autoscale ? false : true
  do_create_node_image                             = local.cluster_or_autoscale && var.node_image_create
  do_create_node_network                           = local.cluster_or_autoscale
  node_image_display_name                          = var.node_image_display_name != "" ? var.node_image_display_name : "${var.name}-node-image-${formatdate("DDMMMYY-hhmm", timestamp())}"
  red5pro_stream_manager_network_security_group_id = module.vcn.red5pro_stream_manager_network_security_group_id
}

################################################################################
# SSH KEY PAIR
################################################################################

# SSH key pair generation
resource "tls_private_key" "red5pro_ssh_key" {
  count     = var.ssh_key_use_existing ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save SSH key pair files to local folder
resource "local_file" "red5pro_ssh_key_pem" {
  count           = var.ssh_key_use_existing ? 0 : 1
  filename        = "./ssh-key-${var.name}.pem"
  content         = tls_private_key.red5pro_ssh_key[0].private_key_pem
  file_permission = "0400"
}
resource "local_file" "red5pro_ssh_key_pub" {
  count    = var.ssh_key_use_existing ? 0 : 1
  filename = "./ssh-key-${var.name}.pub"
  content  = tls_private_key.red5pro_ssh_key[0].public_key_openssh
}

################################################################################
# Virtual Cloud Networks - VCN, SUBNETS AND NETWORK SECURITY GROUPS
################################################################################

module "vcn" {
  source                           = "./module/vcn"
  type                             = var.type
  name                             = var.name
  oracle_compartment_id            = var.oracle_compartment_id
  kafka_standalone_instance_create = var.kafka_standalone_instance_create
  kafka_public_ip                  = var.kafka_public_ip
}
################################################################################
# Red5 Pro Autoscaling Node - Origin/Edge/Transcoders/Relay (OCI Instance)
################################################################################

# Node instance for OCI Custom Image
module "node_image" {
  source                                 = "./module/node-image"
  name                                   = var.name
  node_image_display_name                = local.node_image_display_name
  ssh_public_key                         = local.ssh_public_key
  ssh_private_key                        = local.ssh_private_key
  subnet_id                              = module.vcn.subnet_id
  red5pro_node_network_security_group_id = module.vcn.red5pro_node_network_security_group_id
  path_to_red5pro_build                  = var.path_to_red5pro_build
  red5pro_license_key                    = var.red5pro_license_key
  red5pro_api_enable                     = var.red5pro_api_enable
  red5pro_api_key                        = var.red5pro_api_key
  node_image_instance_type               = var.node_image_instance_type
  node_image_instance_ocpu               = var.node_image_instance_ocpu
  node_image_instance_memory             = var.node_image_instance_memory
  node_image_instance_volume_size        = var.node_image_instance_volume_size
  oracle_compartment_id                  = var.oracle_compartment_id
  oracle_tenancy_ocid                    = var.oracle_tenancy_ocid
  oracle_user_ocid                       = var.oracle_user_ocid
  oracle_fingerprint                     = var.oracle_fingerprint
  oracle_private_key_path                = var.oracle_private_key_path
  oracle_region                          = var.oracle_region
  ubuntu_version                         = var.ubuntu_version
}

################################################################################
# Create/Delete node group (Stream Manager API)
################################################################################
module "node_group" {
  count = var.node_group_create ? 1 : 0

  depends_on = [
    module.vcn,
    null_resource.red5pro_sm[0],
    null_resource.red5pro_kafka[0],
    oci_core_instance.red5pro_sm[0],
    oci_core_instance.red5pro_kafka[0],
    oci_load_balancer_load_balancer.red5pro_lb[0],
    oci_core_instance_pool.red5pro_instance_pool[0],
  ]
  source                               = "./module/node-group"
  name                                 = var.name
  node_group_origins_min               = var.node_group_origins_min
  node_group_origins_max               = var.node_group_origins_max
  node_group_origins_instance_type     = var.node_group_origins_instance_type
  node_group_origins_volume_size       = var.node_group_origins_volume_size
  node_group_edges_min                 = var.node_group_edges_min
  node_group_edges_max                 = var.node_group_edges_max
  node_group_edges_instance_type       = var.node_group_edges_instance_type
  node_group_edges_volume_size         = var.node_group_edges_volume_size
  node_group_transcoders_min           = var.node_group_transcoders_min
  node_group_transcoders_max           = var.node_group_transcoders_max
  node_group_transcoders_instance_type = var.node_group_transcoders_instance_type
  node_group_transcoders_volume_size   = var.node_group_transcoders_volume_size
  node_group_relays_min                = var.node_group_relays_min
  node_group_relays_max                = var.node_group_relays_max
  node_group_relays_instance_type      = var.node_group_relays_instance_type
  node_group_relays_volume_size        = var.node_group_relays_volume_size
  node_config_round_trip_auth          = var.node_config_round_trip_auth
  node_config_webhooks                 = var.node_config_webhooks
  node_config_social_pusher            = var.node_config_social_pusher
  node_config_restreamer               = var.node_config_restreamer
  stream_manager_auth_user             = var.stream_manager_auth_user
  stream_manager_auth_password         = var.stream_manager_auth_password
  stream_manager_ip                    = local.stream_manager_ip
  oracle_region                        = var.oracle_region
  subnet_name                          = module.vcn.subnet_name
  red5pro_node_image_name              = local.node_image_display_name
  red5pro_node_network_security_group  = module.vcn.red5pro_node_network_security_group
}

################################################################################
# Oracle Cloud Infrastructure
################################################################################

# Get latest Canonical Ubuntu image
data "oci_core_images" "ubuntu_image" {
  compartment_id   = var.oracle_compartment_id
  operating_system = "Canonical Ubuntu"
  filter {
    name   = "display_name"
    values = ["^Canonical-Ubuntu-${var.ubuntu_version}-([\\.0-9-]+)$"]
    regex  = true
  }
}

# Get List of Oracle cloud availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oracle_compartment_id
}

################################################################################
# Red5 Pro Standalone Server (OCI Instance)
################################################################################

resource "random_password" "ssl_password_red5pro_standalone" {
  count   = local.standalone && var.https_ssl_certificate != "none" ? 1 : 0
  length  = 16
  special = false
}

resource "oci_core_instance" "red5pro_standalone" {
  count               = local.standalone ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oracle_compartment_id
  shape               = var.standalone_red5pro_instance_type
  display_name        = "${var.name}-standalone-server"

  shape_config {
    ocpus         = var.standalone_red5pro_instance_ocpu
    memory_in_gbs = var.standalone_red5pro_instance_memory
  }

  source_details {
    source_id               = data.oci_core_images.ubuntu_image.images[0].id
    source_type             = "image"
    boot_volume_size_in_gbs = var.standalone_red5pro_instance_volume_size
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_id
    nsg_ids          = [module.vcn.red5pro_standalone_network_security_group_id]
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
  }
  preserve_boot_volume = false

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
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
      "export NODE_INSPECTOR_ENABLE='${var.standalone_red5pro_inspector_enable}'",
      "export NODE_RESTREAMER_ENABLE='${var.standalone_red5pro_restreamer_enable}'",
      "export NODE_SOCIALPUSHER_ENABLE='${var.standalone_red5pro_socialpusher_enable}'",
      "export NODE_SUPPRESSOR_ENABLE='${var.standalone_red5pro_suppressor_enable}'",
      "export NODE_HLS_ENABLE='${var.standalone_red5pro_hls_enable}'",
      "export NODE_ROUND_TRIP_AUTH_ENABLE='${var.standalone_red5pro_round_trip_auth_enable}'",
      "export NODE_ROUND_TRIP_AUTH_HOST='${var.standalone_red5pro_round_trip_auth_host}'",
      "export NODE_ROUND_TRIP_AUTH_PORT='${var.standalone_red5pro_round_trip_auth_port}'",
      "export NODE_ROUND_TRIP_AUTH_PROTOCOL='${var.standalone_red5pro_round_trip_auth_protocol}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE='${var.standalone_red5pro_round_trip_auth_endpoint_validate}'",
      "export NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE='${var.standalone_red5pro_round_trip_auth_endpoint_invalidate}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node_apps_plugins.sh",
      "sudo systemctl daemon-reload && sudo systemctl start red5pro",
      "sudo mkdir -p /usr/local/red5pro/certs",
      "echo '${try(file(var.https_ssl_certificate_cert_path), "")}' | sudo tee -a /usr/local/red5pro/certs/fullchain.pem",
      "echo '${try(file(var.https_ssl_certificate_key_path), "")}' | sudo tee -a /usr/local/red5pro/certs/privkey.pem",
      "export SSL='${var.https_ssl_certificate}'",
      "export SSL_DOMAIN='${var.https_ssl_certificate_domain_name}'",
      "export SSL_MAIL='${var.https_ssl_certificate_email}'",
      "export SSL_PASSWORD='${try(nonsensitive(random_password.ssl_password_red5pro_standalone[0].result), "")}'",
      "export SSL_CERT_PATH=/usr/local/red5pro/certs",
      "nohup sudo -E /home/ubuntu/red5pro-installer/r5p_ssl_check_install.sh >> /home/ubuntu/red5pro-installer/r5p_ssl_check_install.log &",
      "sleep 2"
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }
}

################################################################################
# Kafka keys and certificates
################################################################################

# Generate random admin usernames for Kafka cluster
resource "random_string" "kafka_admin_username" {
  count   = local.cluster_or_autoscale ? 1 : 0
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = false
}

# Generate random client usernames for Kafka cluster
resource "random_string" "kafka_client_username" {
  count   = local.cluster_or_autoscale ? 1 : 0
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = false
}

# Generate random IDs for Kafka cluster
resource "random_id" "kafka_cluster_id" {
  count       = local.cluster_or_autoscale ? 1 : 0
  byte_length = 16
}

# Generate random passwords for Kafka cluster
resource "random_id" "kafka_admin_password" {
  count       = local.cluster_or_autoscale ? 1 : 0
  byte_length = 16
}

# Generate random passwords for Kafka cluster
resource "random_id" "kafka_client_password" {
  count       = local.cluster_or_autoscale ? 1 : 0
  byte_length = 16
}

# Create private key for CA
resource "tls_private_key" "ca_private_key" {
  count     = local.cluster_or_autoscale ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create private key for kafka server certificate 
resource "tls_private_key" "kafka_server_key" {
  count     = local.cluster_or_autoscale ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create self-signed certificate for CA
resource "tls_self_signed_cert" "ca_cert" {
  count           = local.cluster_or_autoscale ? 1 : 0
  private_key_pem = tls_private_key.ca_private_key[0].private_key_pem

  is_ca_certificate = true

  subject {
    country             = "US"
    common_name         = "Infrared5, Inc."
    organization        = "Red5"
    organizational_unit = "Red5 Root Certification Auhtority"
  }

  validity_period_hours = 87600 # 10 years

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "cert_signing",
    "crl_signing",
  ]
}

# Create CSR for server certificate 
resource "tls_cert_request" "kafka_server_csr" {
  count           = local.cluster_or_autoscale ? 1 : 0
  private_key_pem = tls_private_key.kafka_server_key[0].private_key_pem
  ip_addresses    = [local.kafka_ip]
  dns_names       = ["kafka0"]

  subject {
    country             = "US"
    common_name         = "Kafka server"
    organization        = "Infrared5, Inc."
    organizational_unit = "Development"
  }

  depends_on = [oci_core_instance.red5pro_sm, oci_core_instance.red5pro_kafka]
}

# Sign kafka server Certificate by Private CA 
resource "tls_locally_signed_cert" "kafka_server_cert" {
  count = local.cluster_or_autoscale ? 1 : 0
  # CSR by the development servers
  cert_request_pem = tls_cert_request.kafka_server_csr[0].cert_request_pem
  # CA Private key 
  ca_private_key_pem = tls_private_key.ca_private_key[0].private_key_pem
  # CA certificate
  ca_cert_pem = tls_self_signed_cert.ca_cert[0].cert_pem

  validity_period_hours = 1 * 365 * 24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

################################################################################
# Kafka server - (OCI Instance)
################################################################################
resource "oci_core_instance" "red5pro_kafka" {
  count               = local.kafka_standalone_instance ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oracle_compartment_id
  shape               = var.kafka_standalone_instance_type
  display_name        = "${var.name}-kafka"

  shape_config {
    ocpus         = var.kafka_standalone_instance_ocpu
    memory_in_gbs = var.kafka_standalone_instance_memory
  }

  source_details {
    source_id               = data.oci_core_images.ubuntu_image.images[0].id
    source_type             = "image"
    boot_volume_size_in_gbs = var.kafka_standalone_instance_volume_size
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_id
    nsg_ids          = [module.vcn.red5pro_kafka_network_security_group_id]
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
  }

  preserve_boot_volume = false
}

resource "null_resource" "red5pro_kafka" {
  count = local.kafka_standalone_instance ? 1 : 0

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = oci_core_instance.red5pro_kafka[0].public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo iptables -F",
      "sudo netfilter-persistent save",
      "sudo cloud-init status --wait",
      "echo 'ssl.keystore.key=${local.kafka_ssl_keystore_key}' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "echo 'ssl.truststore.certificates=${local.kafka_ssl_truststore_cert}' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "echo 'ssl.keystore.certificate.chain=${local.kafka_ssl_keystore_cert_chain}' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "echo 'listener.name.broker.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${nonsensitive(random_string.kafka_admin_username[0].result)}\" password=\"${nonsensitive(random_id.kafka_admin_password[0].id)}\" user_${nonsensitive(random_string.kafka_admin_username[0].result)}=\"${nonsensitive(random_id.kafka_admin_password[0].id)}\" user_${nonsensitive(random_string.kafka_client_username[0].result)}=\"${nonsensitive(random_id.kafka_client_password[0].id)}\";' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "echo 'listener.name.controller.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${nonsensitive(random_string.kafka_admin_username[0].result)}\" password=\"${nonsensitive(random_id.kafka_admin_password[0].id)}\" user_${nonsensitive(random_string.kafka_admin_username[0].result)}=\"${nonsensitive(random_id.kafka_admin_password[0].id)}\" user_${nonsensitive(random_string.kafka_client_username[0].result)}=\"${nonsensitive(random_id.kafka_client_password[0].id)}\";' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "echo 'advertised.listeners=BROKER://${local.kafka_ip}:9092' | sudo tee -a /home/ubuntu/red5pro-installer/server.properties",
      "export KAFKA_ARCHIVE_URL='${var.kafka_standalone_instance_arhive_url}'",
      "export KAFKA_CLUSTER_ID='${random_id.kafka_cluster_id[0].b64_std}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_kafka_install.sh",
    ]

    connection {
      host        = oci_core_instance.red5pro_kafka[0].public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }

  depends_on = [tls_cert_request.kafka_server_csr]
}

################################################################################
# Red5 Pro Stream Manager 2.0 - (OCI Instance)
################################################################################

# Generate random password for Red5 Pro Stream Manager 2.0 authentication
resource "random_password" "r5as_auth_secret" {
  count   = local.cluster_or_autoscale ? 1 : 0
  length  = 32
  special = false
}

resource "oci_core_instance" "red5pro_sm" {
  count               = local.cluster_or_autoscale ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oracle_compartment_id
  shape               = var.stream_manager_instance_type
  display_name        = local.autoscale ? "${var.name}-sm2-image" : "${var.name}-sm2"

  shape_config {
    ocpus         = var.stream_manager_instance_ocpu
    memory_in_gbs = var.stream_manager_instance_memory
  }

  source_details {
    source_id               = data.oci_core_images.ubuntu_image.images[0].id
    source_type             = "image"
    boot_volume_size_in_gbs = var.stream_manager_instance_volume_size
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_id
    nsg_ids          = [local.red5pro_stream_manager_network_security_group_id]
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
    user_data = base64gzip(<<-EOF
          #!/bin/bash
          mkdir -p /usr/local/stream-manager/keys
          mkdir -p /usr/local/stream-manager/certs
          echo "${try(file(var.https_ssl_certificate_cert_path), "")}" > /usr/local/stream-manager/certs/cert.pem
          echo "${try(file(var.https_ssl_certificate_key_path), "")}" > /usr/local/stream-manager/certs/privkey.pem
          echo -n "${local.ssh_public_key}" > /usr/local/stream-manager/keys/red5pro_ssh_public_key.pub
          echo "${try(file(var.oracle_private_key_path), "")}" > /usr/local/stream-manager/keys/oracle_private_api_key.pem
          chmod 400 /usr/local/stream-manager/keys/privkey.pem
          chmod 400 /usr/local/stream-manager/keys/oracle_private_api_key.pem
          ############################ .env file #########################################################
          cat >> /usr/local/stream-manager/.env <<- EOM
          KAFKA_CLUSTER_ID=${random_id.kafka_cluster_id[0].b64_std}
          KAFKA_ADMIN_USERNAME=${random_string.kafka_admin_username[0].result}
          KAFKA_ADMIN_PASSWORD=${random_id.kafka_admin_password[0].id}
          KAFKA_CLIENT_USERNAME=${random_string.kafka_client_username[0].result}
          KAFKA_CLIENT_PASSWORD=${random_id.kafka_client_password[0].id}
          R5AS_AUTH_SECRET=${random_password.r5as_auth_secret[0].result}
          R5AS_AUTH_USER=${var.stream_manager_auth_user}
          R5AS_AUTH_PASS=${var.stream_manager_auth_password}
          TF_VAR_oci_tenancy_ocid=${var.oracle_tenancy_ocid}
          TF_VAR_oci_user_ocid=${var.oracle_user_ocid}
          TF_VAR_oci_compartment_id=${var.oracle_compartment_id}
          TF_VAR_oci_fingerprint=${var.oracle_fingerprint}
          TF_VAR_r5p_license_key=${var.red5pro_license_key}
          TRAEFIK_TLS_CHALLENGE=${local.stream_manager_ssl == "letsencrypt" ? "true" : "false"}
          TRAEFIK_HOST=${var.https_ssl_certificate_domain_name}
          TRAEFIK_SSL_EMAIL=${var.https_ssl_certificate_email}
          TRAEFIK_CMD=${local.stream_manager_ssl == "imported" ? "--providers.file.filename=/scripts/traefik.yaml" : ""}
        EOF
    )
  }
  preserve_boot_volume = false
}

resource "null_resource" "red5pro_sm" {
  count = local.cluster_or_autoscale ? 1 : 0

  provisioner "file" {
    source      = "${abspath(path.module)}/red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = oci_core_instance.red5pro_sm[0].public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo iptables -F",
      "sudo netfilter-persistent save",
      "sudo cloud-init status --wait",
      "echo 'KAFKA_SSL_KEYSTORE_KEY=${local.kafka_ssl_keystore_key}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'KAFKA_SSL_TRUSTSTORE_CERTIFICATES=${local.kafka_ssl_truststore_cert}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'KAFKA_SSL_KEYSTORE_CERTIFICATE_CHAIN=${local.kafka_ssl_keystore_cert_chain}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'KAFKA_REPLICAS=${local.kafka_on_sm_replicas}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'KAFKA_IP=${local.kafka_ip}' | sudo tee -a /usr/local/stream-manager/.env",
      "echo 'TRAEFIK_IP=${oci_core_instance.red5pro_sm[0].public_ip}' | sudo tee -a /usr/local/stream-manager/.env",
      "export SM_SSL='${local.stream_manager_ssl}'",
      "export SM_STANDALONE='${local.stream_manager_standalone}'",
      "export SM_SSL_DOMAIN='${var.https_ssl_certificate_domain_name}'",
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_sm2_oci.sh",
    ]
    connection {
      host        = oci_core_instance.red5pro_sm[0].public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.ssh_private_key
    }
  }
  depends_on = [tls_cert_request.kafka_server_csr, null_resource.red5pro_kafka]
}

################################################################################
# Red5 Pro Stream Manager Autoscaling (OCI Load Balancer + Autoscaling)
################################################################################
data "oci_core_public_ip" "red5pro_reserved_ip" {
  count      = local.autoscale && var.load_balancer_reserved_ip_use_existing ? 1 : 0
  ip_address = var.load_balancer_reserved_ip_existing
}

resource "oci_core_public_ip" "red5pro_reserved_ip" {
  count          = local.autoscale && var.load_balancer_reserved_ip_use_existing == false ? 1 : 0
  compartment_id = var.oracle_compartment_id
  lifetime       = "RESERVED"

  lifecycle {
    ignore_changes = [private_ip_id]
  }
}

resource "oci_load_balancer_load_balancer" "red5pro_lb" {
  count                      = local.autoscale ? 1 : 0
  display_name               = "${var.name}-sm2-lb"
  compartment_id             = var.oracle_compartment_id
  subnet_ids                 = [local.subnet_id]
  network_security_group_ids = [local.red5pro_stream_manager_network_security_group_id]
  shape                      = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = 100
    minimum_bandwidth_in_mbps = 10
  }
  reserved_ips {
    id = local.load_balancer_reserved_ip_id
  }
}

resource "oci_load_balancer_backend_set" "red5pro_lb_backend_set" {
  count            = local.autoscale ? 1 : 0
  name             = "${var.name}-lb-set"
  load_balancer_id = oci_load_balancer_load_balancer.red5pro_lb[0].id
  policy           = "ROUND_ROBIN"

  health_checker {
    port        = "80"
    protocol    = "HTTP"
    return_code = 200
    url_path    = "/as/v1/admin/healthz"
  }
}

resource "oci_load_balancer_listener" "red5pro_lb_listener_http" {
  count                    = local.autoscale ? 1 : 0
  load_balancer_id         = oci_load_balancer_load_balancer.red5pro_lb[0].id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.red5pro_lb_backend_set[0].name
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

resource "oci_load_balancer_listener" "red5pro_lb_listener_https" {
  count                    = local.autoscale && var.https_ssl_certificate == "imported" ? 1 : 0
  load_balancer_id         = oci_load_balancer_load_balancer.red5pro_lb[0].id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.red5pro_lb_backend_set[0].name
  port                     = 443
  protocol                 = "HTTP"

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.red5pro_lb_ssl_cert[0].certificate_name
    verify_peer_certificate = false
    cipher_suite_name       = var.lb_https_certificate_cipher_suite_name
    protocols               = ["TLSv1.1", "TLSv1.2"]
    server_order_preference = "ENABLED"
  }
}

# OCI LB SSL certificate
resource "oci_load_balancer_certificate" "red5pro_lb_ssl_cert" {
  count            = local.autoscale && var.https_ssl_certificate == "imported" ? 1 : 0
  load_balancer_id = oci_load_balancer_load_balancer.red5pro_lb[0].id
  certificate_name = var.https_ssl_certificate_domain_name
  # ca_certificate     = var.lb_https_certificate_fullchain != "" ? file(var.lb_https_certificate_fullchain) : null
  private_key        = file(var.https_ssl_certificate_key_path)
  public_certificate = file(var.https_ssl_certificate_cert_path)

  lifecycle {
    create_before_destroy = true
  }
}

# OCI SM AUTOSCALING
resource "oci_core_image" "red5pro_sm_image" {
  count          = local.autoscale ? 1 : 0
  compartment_id = var.oracle_compartment_id
  instance_id    = oci_core_instance.red5pro_sm[0].id
  display_name   = "${var.name}-stream-manager"
  depends_on     = [null_resource.red5pro_sm]
}

resource "oci_core_instance_configuration" "red5pro_instance_configuration" {
  count          = local.autoscale ? 1 : 0
  compartment_id = var.oracle_compartment_id
  display_name   = "${var.name}-sm-instance-cnf"

  instance_details {
    instance_type = "compute"

    launch_details {
      display_name   = "${var.name}-sm-instance-ld"
      compartment_id = var.oracle_compartment_id
      shape          = var.stream_manager_instance_type

      create_vnic_details {
        subnet_id        = local.subnet_id
        display_name     = "${var.name}-sm-instance"
        assign_public_ip = true
        nsg_ids          = [local.red5pro_stream_manager_network_security_group_id]
      }

      shape_config {
        ocpus         = var.stream_manager_instance_ocpu
        memory_in_gbs = var.stream_manager_instance_memory
      }

      source_details {
        source_type = "image"
        image_id    = oci_core_image.red5pro_sm_image[0].id
      }

      metadata = {
        ssh_authorized_keys = local.ssh_public_key
      }
    }
  }
}

resource "oci_core_instance_pool" "red5pro_instance_pool" {
  count                           = local.autoscale ? 1 : 0
  compartment_id                  = var.oracle_compartment_id
  instance_configuration_id       = oci_core_instance_configuration.red5pro_instance_configuration[0].id
  size                            = 1
  state                           = "RUNNING"
  display_name                    = "${var.name}-sm2-pool"
  instance_display_name_formatter = "${var.name}-sm2-$${launchCount}"
  #instance_hostname_formatter     = "${var.name}-sm2-$${launchCount}"

  placement_configurations {
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    primary_subnet_id   = local.subnet_id
  }

  load_balancers {
    backend_set_name = oci_load_balancer_backend_set.red5pro_lb_backend_set[0].name
    load_balancer_id = oci_load_balancer_load_balancer.red5pro_lb[0].id
    port             = 80
    vnic_selection   = "primaryvnic"
  }
}

resource "oci_autoscaling_auto_scaling_configuration" "red5pro_autoscaling_configuration" {
  count                = local.autoscale ? 1 : 0
  compartment_id       = var.oracle_compartment_id
  cool_down_in_seconds = "300"
  display_name         = "${var.name}-autoscale-cnf"
  is_enabled           = "true"

  policies {
    capacity {
      initial = var.stream_manager_autoscaling_desired_capacity
      max     = var.stream_manager_autoscaling_maximum_capacity
      min     = var.stream_manager_autoscaling_minimum_capacity
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
# Stop instances which used for creating OCI custom images (OCI CLI)
################################################################################
# Stream Manager autoscaling - Stop Stream Manager instance using OCI CLI
resource "null_resource" "stop_stream_manager" {
  count = local.autoscale ? 1 : 0
  provisioner "local-exec" {
    command = "oci compute instance action --action STOP --instance-id ${oci_core_instance.red5pro_sm[0].id}"
    environment = {
      OCI_CLI_USER                              = "${var.oracle_user_ocid}"
      OCI_CLI_FINGERPRINT                       = "${var.oracle_fingerprint}"
      OCI_CLI_TENANCY                           = "${var.oracle_tenancy_ocid}"
      OCI_CLI_REGION                            = "${var.oracle_region}"
      OCI_CLI_KEY_FILE                          = "${var.oracle_private_key_path}"
      OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING = "True"
    }
  }
  depends_on = [oci_core_image.red5pro_sm_image[0]]
}
