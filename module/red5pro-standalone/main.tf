locals {
  ssh_private_key_path                             = var.ssh_key_use_existing ? var.ssh_key_existing_private_key_path : local_file.red5pro_ssh_key_pem[0].filename
  ssh_public_key_path                              = var.ssh_key_use_existing ? var.ssh_key_existing_public_key_path : local_file.red5pro_ssh_key_pub[0].filename
  ssh_private_key                                  = var.ssh_key_use_existing ? file(var.ssh_key_existing_private_key_path) : tls_private_key.red5pro_ssh_key[0].private_key_pem
  ssh_public_key                                   = var.ssh_key_use_existing ? file(var.ssh_key_existing_public_key_path) : tls_private_key.red5pro_ssh_key[0].public_key_openssh
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
  count   = var.https_ssl_certificate != "none" ? 1 : 0
  length  = 16
  special = false
}

resource "oci_core_instance" "red5pro_standalone" {
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
    subnet_id        = var.subnet_id
    nsg_ids          = [var.red5pro_standalone_network_security_group_id]
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
  }
  preserve_boot_volume = false

  provisioner "file" {
    source      = "${abspath(path.module)}/../../red5pro-installer"
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
