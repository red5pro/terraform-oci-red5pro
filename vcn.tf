################################################################################
# Virtual Cloud Networks - VCN, SUBNETS AND NETWORK SECURITY GROUPS
################################################################################

locals {
  network_security_group_kafka_ingress_src = var.kafka_public_ip ? "0.0.0.0/0" : "10.5.0.0/16"
  network_security_group_kafka_ingress = length(var.network_security_group_kafka_ingress) == 0 ? [
    {
      description = "Kafka standalone instance - SSH (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 22
      port_max    = 22
    },
    {
      description = "Kafka standalone instance - Kafka (TCP)"
      protocol    = "6"
      source      = "${local.network_security_group_kafka_ingress_src}"
      port_min    = 9092
      port_max    = 9092
    }
  ] : var.network_security_group_kafka_ingress
  network_security_group_stream_manager_ingress = length(var.network_security_group_stream_manager_ingress) == 0 ? [
    {
      description = "Stream Manager 2.0 - SSH (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 22
      port_max    = 22
    },
    {
      description = "Stream Manager 2.0 - HTTP (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 80
      port_max    = 80
    },
    {
      description = "Stream Manager 2.0 - HTTPS (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 443
      port_max    = 443
    },
    {
      description = "Stream Manager 2.0 - Kafka (TCP)"
      protocol    = "6"
      source      = "${local.network_security_group_kafka_ingress_src}"
      port_min    = 9092
      port_max    = 9092
    }
  ] : var.network_security_group_stream_manager_ingress
}

# Create a new VCN
resource "oci_core_vcn" "red5pro_vcn" {
  cidr_blocks    = [var.vcn_cidr_block]
  compartment_id = var.oracle_compartment_id
  display_name   = "${var.name}-vcn"
  is_ipv6enabled = false

  lifecycle {
    ignore_changes = [dns_label]
  }
}

resource "oci_core_internet_gateway" "red5pro_internet_gateway" {
  compartment_id = var.oracle_compartment_id
  vcn_id         = oci_core_vcn.red5pro_vcn.id
  enabled        = true
  display_name   = "${var.name}-internet-gateway"
}

resource "oci_core_route_table" "red5pro_route_table" {
  compartment_id = var.oracle_compartment_id
  vcn_id         = oci_core_vcn.red5pro_vcn.id
  display_name   = "${var.name}-route-table"
  route_rules {
    network_entity_id = oci_core_internet_gateway.red5pro_internet_gateway.id
    description       = "Default IPv4 Route Rule"
    destination       = "0.0.0.0/0"
  }
}

# Default VCN Network Security List
resource "oci_core_security_list" "red5pro_security_list" {
  compartment_id = var.oracle_compartment_id
  display_name   = "${var.name}-security-list"
  vcn_id         = local.vcn_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# Create a new Public Subnet
resource "oci_core_subnet" "red5pro_vcn_subnet_public" {
  cidr_block                 = var.subnet_cidr_block
  compartment_id             = var.oracle_compartment_id
  vcn_id                     = oci_core_vcn.red5pro_vcn.id
  display_name               = "${var.name}-public-subnet"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.red5pro_route_table.id
  security_list_ids          = [oci_core_security_list.red5pro_security_list.id]

  lifecycle {
    ignore_changes = [dns_label]
  }
}

resource "oci_core_route_table_attachment" "red5pro_route_table_attachment" {
  subnet_id      = oci_core_subnet.red5pro_vcn_subnet_public.id
  route_table_id = oci_core_route_table.red5pro_route_table.id
}

# Network Security group for Standalone Red5Pro server
resource "oci_core_network_security_group" "red5pro_standalone_network_security_group" {
  count          = local.standalone ? 1 : 0
  compartment_id = var.oracle_compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.name}-standalone-nsg"
}

resource "oci_core_network_security_group_security_rule" "red5pro_standalone_nsg_security_rule_ingress" {
  count                     = local.standalone ? length(var.network_security_group_standalone_ingress) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_standalone_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = var.network_security_group_standalone_ingress[count.index].protocol
  description               = var.network_security_group_standalone_ingress[count.index].description
  source                    = var.network_security_group_standalone_ingress[count.index].source
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  dynamic "tcp_options" {
    for_each = var.network_security_group_standalone_ingress[count.index].protocol == "6" ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_standalone_ingress[count.index].port_min
        max = var.network_security_group_standalone_ingress[count.index].port_max
      }
    }
  }
  dynamic "udp_options" {
    for_each = var.network_security_group_standalone_ingress[count.index].protocol == "17" ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_standalone_ingress[count.index].port_min
        max = var.network_security_group_standalone_ingress[count.index].port_max
      }
    }
  }
  # lifecycle {
  #   ignore_changes = [direction, protocol, source, source_type, tcp_options]
  # }
}

# Network Security group for Stream Manager
resource "oci_core_network_security_group" "red5pro_stream_manager_network_security_group" {
  count          = local.cluster_or_autoscale ? 1 : 0
  compartment_id = var.oracle_compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.name}-sm2-nsg"
}

resource "oci_core_network_security_group_security_rule" "red5pro_stream_manager_nsg_security_rule_ingress" {
  count                     = local.cluster_or_autoscale ? length(local.network_security_group_stream_manager_ingress) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_stream_manager_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = local.network_security_group_stream_manager_ingress[count.index].protocol
  description               = local.network_security_group_stream_manager_ingress[count.index].description
  source                    = local.network_security_group_stream_manager_ingress[count.index].source
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  dynamic "tcp_options" {
    for_each = local.network_security_group_stream_manager_ingress[count.index].protocol == "6" ? [1] : []
    content {
      destination_port_range {
        min = local.network_security_group_stream_manager_ingress[count.index].port_min
        max = local.network_security_group_stream_manager_ingress[count.index].port_max
      }
    }
  }
  dynamic "udp_options" {
    for_each = local.network_security_group_stream_manager_ingress[count.index].protocol == "17" ? [1] : []
    content {
      destination_port_range {
        min = local.network_security_group_stream_manager_ingress[count.index].port_min
        max = local.network_security_group_stream_manager_ingress[count.index].port_max
      }
    }
  }
  # lifecycle {
  #   ignore_changes = [direction, protocol, source, source_type, tcp_options]
  # }
}

# Network Security group for SM Nodes
resource "oci_core_network_security_group" "red5pro_node_network_security_group" {
  count          = local.do_create_node_network ? 1 : 0
  compartment_id = var.oracle_compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.name}-node-nsg"
}

resource "oci_core_network_security_group_security_rule" "red5pro_node_nsg_security_rule_ingress" {
  count                     = local.do_create_node_network ? length(var.network_security_group_node_ingress) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_node_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = var.network_security_group_node_ingress[count.index].protocol
  description               = var.network_security_group_node_ingress[count.index].description
  source                    = var.network_security_group_node_ingress[count.index].source
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  dynamic "tcp_options" {
    for_each = var.network_security_group_node_ingress[count.index].protocol == "6" ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_node_ingress[count.index].port_min
        max = var.network_security_group_node_ingress[count.index].port_max
      }
    }
  }
  dynamic "udp_options" {
    for_each = var.network_security_group_node_ingress[count.index].protocol == "17" ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_node_ingress[count.index].port_min
        max = var.network_security_group_node_ingress[count.index].port_max
      }
    }
  }
  # lifecycle {
  #   ignore_changes = [direction, protocol, source, source_type, tcp_options]
  # }
}

# Network Security group for Kafka server
resource "oci_core_network_security_group" "red5pro_kafka_network_security_group" {
  count          = local.kafka_standalone_instance ? 1 : 0
  compartment_id = var.oracle_compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.name}-kafka-nsg"
}

resource "oci_core_network_security_group_security_rule" "red5pro_kafka_nsg_security_rule_ingress" {
  count                     = local.kafka_standalone_instance ? length(local.network_security_group_kafka_ingress) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_kafka_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = local.network_security_group_kafka_ingress[count.index].protocol
  description               = local.network_security_group_kafka_ingress[count.index].description
  source                    = local.network_security_group_kafka_ingress[count.index].source
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  dynamic "tcp_options" {
    for_each = local.network_security_group_kafka_ingress[count.index].protocol == "6" ? [1] : []
    content {
      destination_port_range {
        min = local.network_security_group_kafka_ingress[count.index].port_min
        max = local.network_security_group_kafka_ingress[count.index].port_max
      }
    }
  }
  dynamic "udp_options" {
    for_each = local.network_security_group_kafka_ingress[count.index].protocol == "17" ? [1] : []
    content {
      destination_port_range {
        min = local.network_security_group_kafka_ingress[count.index].port_min
        max = local.network_security_group_kafka_ingress[count.index].port_max
      }
    }
  }
  # lifecycle {
  #   ignore_changes = [direction, protocol, source, source_type, tcp_options]
  # }
}
