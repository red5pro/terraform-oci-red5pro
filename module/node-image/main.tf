
################################################################################
# Red5 Pro Autoscaling Node - Origin/Edge/Transcoders/Relay (OCI Instance)
################################################################################

# Node instance for OCI Custom Image
resource "oci_core_instance" "red5pro_node" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.oracle_compartment_id
  shape               = var.node_image_instance_type
  display_name        = "${var.name}-node-image"

  shape_config {
    ocpus         = var.node_image_instance_ocpu
    memory_in_gbs = var.node_image_instance_memory
  }

  source_details {
    source_id               = data.oci_core_images.ubuntu_image.images[0].id
    source_type             = "image"
    boot_volume_size_in_gbs = var.node_image_instance_volume_size
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = var.subnet_id
    nsg_ids          = [var.red5pro_node_network_security_group_id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  preserve_boot_volume = false

  provisioner "file" {
    source      = "${abspath(path.module)}/../../red5pro-installer"
    destination = "/home/ubuntu"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.ssh_private_key
    }
  }

  provisioner "file" {
    source      = var.path_to_red5pro_build
    destination = "/home/ubuntu/red5pro-installer/${basename(var.path_to_red5pro_build)}"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.ssh_private_key
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
      "cd /home/ubuntu/red5pro-installer/",
      "sudo chmod +x /home/ubuntu/red5pro-installer/*.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_install_server_basic.sh",
      "sudo -E /home/ubuntu/red5pro-installer/r5p_config_node.sh",
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.ssh_private_key
    }
  }
}

####################################################################################################
# Red5 Pro Autoscaling Nodes create images - Origin/Edge/Transcoders/Relay (OCI Custom Images)
####################################################################################################

# Node - Create image (OCI Custom Images)
resource "oci_core_image" "red5pro_node_image" {
  compartment_id = var.oracle_compartment_id
  instance_id    = oci_core_instance.red5pro_node.id
  display_name   = var.node_image_display_name
  depends_on     = [oci_core_instance.red5pro_node]
  lifecycle {
    ignore_changes = [display_name]
  }
}

################################################################################
# Stop instances which used for creating OCI custom images (OCI CLI)
################################################################################

# Stop Node instance using OCI CLI
resource "null_resource" "stop_node" {
  provisioner "local-exec" {
    command = "oci compute instance action --action STOP --instance-id ${oci_core_instance.red5pro_node.id}"
    environment = {
      OCI_CLI_USER                              = "${var.oracle_user_ocid}"
      OCI_CLI_FINGERPRINT                       = "${var.oracle_fingerprint}"
      OCI_CLI_TENANCY                           = "${var.oracle_tenancy_ocid}"
      OCI_CLI_REGION                            = "${var.oracle_region}"
      OCI_CLI_KEY_FILE                          = "${var.oracle_private_key_path}"
      OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING = "True"
    }
  }
  depends_on = [oci_core_image.red5pro_node_image]
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
