################################################################################
# Virtual Cloud Networks - VCN, SUBNETS AND NETWORK SECURITY GROUPS
################################################################################

# Get details of the existing VCN
data "oci_core_vcn" "red5pro_existing_vcn" {
  count = var.vcn_create ? 0 : 1
  vcn_id = var.vcn_id_existing

  lifecycle {
    postcondition {
      condition     = self.vcn_id != null && self.vcn_id != ""
      error_message = "ERROR! VCN with ID ${var.vcn_id_existing} does not exist in the compartment ${var.compartment_id}"
    }
  }
}

# Get details of the existing Subnet
data "oci_core_subnet" "red5pro_existing_subnet" {
  count = var.vcn_create ? 0 : 1
  subnet_id = var.subnet_id_existing

  lifecycle {
    postcondition {
      condition     = self.subnet_id != null && self.subnet_id != ""
      error_message = "ERROR! Subnet with ID ${var.subnet_id_existing} does not exist in the compartment ${var.compartment_id}"
    }
  }
}

# Get details of the existing Network Security Group
data "oci_core_network_security_group" "red5pro_existing_network_security_group" {
  count = var.network_security_group_create ? 0 : 1
  network_security_group_id = var.network_security_group_id_existing

  lifecycle {
    postcondition {
      condition     = self.network_security_group_id != null && self.network_security_group_id != ""
      error_message = "ERROR! Network Security Group with ID ${var.network_security_group_id_existing} does not exist in the compartment ${var.compartment_id}"
    }
  }
}

# Create a new VCN if input variable vcn_create is true
resource "oci_core_vcn" "red5pro_vcn" {
  count          = var.vcn_create ? 1 : 0
  cidr_blocks    = ["10.5.0.0/16"]
  compartment_id = var.compartment_id
  display_name   = "${var.name}-vcn"
  is_ipv6enabled = local.enable_ipv6
  defined_tags   = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, dns_label]
  }
}

resource "oci_core_internet_gateway" "red5pro_internet_gateway" {
  count          = var.vcn_create ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.red5pro_vcn[0].id
  enabled        = true
  display_name   = "${var.name}-internet-gateway"
  defined_tags   = var.defined_tags
}

resource "oci_core_route_table" "red5pro_route_table" {
  count          = var.vcn_create ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.red5pro_vcn[0].id
  display_name   = "${var.name}-route-table"
  defined_tags   = var.defined_tags
  route_rules {
    network_entity_id = oci_core_internet_gateway.red5pro_internet_gateway[0].id
    description       = "Default IPv4 Route Rule"
    destination       = "0.0.0.0/0"
  }
  dynamic "route_rules" {
    for_each = local.enable_ipv6 == true ? [1] : []
    content {
      network_entity_id = oci_core_internet_gateway.red5pro_internet_gateway[0].id
      description       = "Default IPv6 Route Rule"
      destination       = "::/0"
    }
  }
}

# Oracle Cloud Default VCN Network Security List
resource "oci_core_security_list" "red5pro_security_list" {
  count          = var.vcn_create ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.name}-security-list"
  vcn_id         = oci_core_vcn.red5pro_vcn[0].id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "10.5.0.0/16"
    tcp_options {
      min = 3306
      max = 3306
    }
  }
}

# Create a new Public Subnet if input variable vcn_create is true
resource "oci_core_subnet" "red5pro_vcn_subnet_public" {
  count                      = var.vcn_create ? 1 : 0
  cidr_block                 = "10.5.1.0/24"
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.red5pro_vcn[0].id
  display_name               = "${var.name}-subnet-public"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.red5pro_route_table[0].id
  security_list_ids          = [oci_core_security_list.red5pro_security_list[0].id]
  defined_tags               = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, dns_label]
  }
}

resource "oci_core_route_table_attachment" "red5pro_route_table_attachment" {
  count          = var.vcn_create ? 1 : 0
  subnet_id      = oci_core_subnet.red5pro_vcn_subnet_public[0].id
  route_table_id = oci_core_route_table.red5pro_route_table[0].id
}

# Oracle Cloud Network Security group for Single Red5Pro server
resource "oci_core_network_security_group" "red5pro_single_network_security_group" {
  count          = local.single && var.network_security_group_create ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.name}-single-nsg"
  defined_tags   = var.defined_tags
}

resource "oci_core_network_security_group_security_rule" "red5pro_single_nsg_rule_egress" {
  count                     = local.single && var.network_security_group_create ? 1 : 0
  network_security_group_id = oci_core_network_security_group.red5pro_single_network_security_group[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  description               = "Egress Security Group Rule - Allow all outbound traffic"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  stateless                 = false

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "red5pro_single_nsg_security_rule_ingress_tcp" {
  count                     = local.single && var.network_security_group_create ? length(var.network_security_group_single_ingress_tcp) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_single_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  description               = "Ingress Security Group Rule for TCP Port ${var.network_security_group_single_ingress_tcp[count.index]}"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  tcp_options {
    destination_port_range {
      max = var.network_security_group_single_ingress_tcp[count.index]
      min = var.network_security_group_single_ingress_tcp[count.index]
    }
  }

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "red5pro_single_nsg_security_rule_ingress_udp" {
  count                     = local.single && var.network_security_group_create ? length(var.network_security_group_single_ingress_udp) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_single_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = "17"
  description               = "Ingress Security Group Rule for UDP Port Range ${lookup(var.network_security_group_single_ingress_udp[count.index], "from_port")}-${lookup(var.network_security_group_single_ingress_udp[count.index], "to_port")}"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  udp_options {
    destination_port_range {
      min = lookup(var.network_security_group_single_ingress_udp[count.index], "from_port")
      max = lookup(var.network_security_group_single_ingress_udp[count.index], "to_port")
    }
  }

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, udp_options]
  }
}

# Oracle Cloud Network Security group for Stream Manager
resource "oci_core_network_security_group" "red5pro_stream_manager_network_security_group" {
  count          = local.cluster || local.autoscaling ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.red5pro_vcn[0].id
  display_name   = "${var.name}-sm-nsg"
  defined_tags   = var.defined_tags
}

resource "oci_core_network_security_group_security_rule" "red5pro_stream_manager_nsg_rule_egress" {
  count                     = local.cluster || local.autoscaling ? 1 : 0
  network_security_group_id = oci_core_network_security_group.red5pro_stream_manager_network_security_group[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  description               = "Egress Security Group Rule - Allow all outbound traffic"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  stateless                 = false

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "red5pro_stream_manager_nsg_security_rule_ingress_tcp" {
  count                     = local.cluster || local.autoscaling ? length(var.network_security_group_stream_manager_ingress_tcp) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_stream_manager_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  description               = "Ingress Security Group Rule for TCP Port ${var.network_security_group_stream_manager_ingress_tcp[count.index]}"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  tcp_options {
    destination_port_range {
      max = var.network_security_group_stream_manager_ingress_tcp[count.index]
      min = var.network_security_group_stream_manager_ingress_tcp[count.index]
    }
  }

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

# Oracle Cloud Network Security group for Red5 Pro Terraform Service
resource "oci_core_network_security_group" "red5pro_terraform_service_network_security_group" {
  count          = local.cluster || local.autoscaling ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.red5pro_vcn[0].id
  display_name   = "${var.name}-sm-nsg"
  defined_tags   = var.defined_tags
}

resource "oci_core_network_security_group_security_rule" "red5pro_terraform_service_nsg_rule_egress" {
  count                     = local.cluster || local.autoscaling ? 1 : 0
  network_security_group_id = oci_core_network_security_group.red5pro_terraform_service_network_security_group[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  description               = "Egress Security Group Rule - Allow all outbound traffic"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  stateless                 = false

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "red5pro_terraform_service_nsg_security_rule_ingress_tcp" {
  count                     = local.cluster || local.autoscaling ? length(var.network_security_group_terraform_service_ingress_tcp) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_terraform_service_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  description               = "Ingress Security Group Rule for TCP Port ${var.network_security_group_terraform_service_ingress_tcp[count.index]}"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  tcp_options {
    destination_port_range {
      max = var.network_security_group_terraform_service_ingress_tcp[count.index]
      min = var.network_security_group_terraform_service_ingress_tcp[count.index]
    }
  }

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

# Oracle Cloud Network Security group for SM Nodes
resource "oci_core_network_security_group" "red5pro_node_network_security_group" {
  count          = local.cluster || local.autoscaling ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.red5pro_vcn[0].id
  display_name   = "${var.name}-node-nsg"
  defined_tags   = var.defined_tags
}

resource "oci_core_network_security_group_security_rule" "red5pro_node_nsg_rule_egress" {
  count                     = local.cluster || local.autoscaling ? 1 : 0
  network_security_group_id = oci_core_network_security_group.red5pro_node_network_security_group[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  description               = "Egress Security Group Rule - Allow all outbound traffic"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  stateless                 = false

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "red5pro_node_nsg_security_rule_ingress_tcp" {
  count                     = local.cluster || local.autoscaling ? length(var.network_security_group_node_ingress_tcp) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_node_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  description               = "Ingress Security Group Rule for TCP Port ${var.network_security_group_node_ingress_tcp[count.index]}"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  tcp_options {
    destination_port_range {
      max = var.network_security_group_node_ingress_tcp[count.index]
      min = var.network_security_group_node_ingress_tcp[count.index]
    }
  }

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "red5pro_node_nsg_security_rule_ingress_udp" {
  count                     = local.cluster || local.autoscaling ? length(var.network_security_group_node_ingress_udp) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_node_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = "17"
  description               = "Ingress Security Group Rule for UDP Port Range ${lookup(var.network_security_group_node_ingress_udp[count.index], "from_port")}-${lookup(var.network_security_group_node_ingress_udp[count.index], "to_port")}"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  udp_options {
    destination_port_range {
      min = lookup(var.network_security_group_node_ingress_udp[count.index], "from_port")
      max = lookup(var.network_security_group_node_ingress_udp[count.index], "to_port")
    }
  }

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, udp_options]
  }
}
