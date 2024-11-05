################################################################################
# Virtual Cloud Networks - VCN, SUBNETS AND NETWORK SECURITY GROUPS
################################################################################

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
    for_each = var.network_security_group_standalone_ingress[count.index].protocol == 6 ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_standalone_ingress[count.index].port_min
        max = var.network_security_group_standalone_ingress[count.index].port_max
      }
    }
  }
  dynamic "udp_options" {
    for_each = var.network_security_group_standalone_ingress[count.index].protocol == 17 ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_standalone_ingress[count.index].port_min
        max = var.network_security_group_standalone_ingress[count.index].port_max
      }
    }
  }
  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

# Network Security group for Stream Manager
resource "oci_core_network_security_group" "red5pro_stream_manager_network_security_group" {
  count          = local.cluster_or_autoscale ? 1 : 0
  compartment_id = var.oracle_compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.name}-sm2-nsg"
}

resource "oci_core_network_security_group_security_rule" "red5pro_stream_manager_nsg_security_rule_ingress" {
  count                     = local.cluster_or_autoscale ? length(var.network_security_group_stream_manager_ingress) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_stream_manager_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = var.network_security_group_stream_manager_ingress[count.index].protocol
  description               = var.network_security_group_stream_manager_ingress[count.index].description
  source                    = var.network_security_group_stream_manager_ingress[count.index].source
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  dynamic "tcp_options" {
    for_each = var.network_security_group_stream_manager_ingress[count.index].protocol == 6 ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_stream_manager_ingress[count.index].port_min
        max = var.network_security_group_stream_manager_ingress[count.index].port_max
      }
    }
  }
  dynamic "udp_options" {
    for_each = var.network_security_group_stream_manager_ingress[count.index].protocol == 17 ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_stream_manager_ingress[count.index].port_min
        max = var.network_security_group_stream_manager_ingress[count.index].port_max
      }
    }
  }
  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

# Network Security group for SM Nodes
resource "oci_core_network_security_group" "red5pro_node_network_security_group" {
  count          = local.cluster_or_autoscale ? 1 : 0
  compartment_id = var.oracle_compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.name}-node-nsg"
}

resource "oci_core_network_security_group_security_rule" "red5pro_node_nsg_security_rule_ingress" {
  count                     = local.cluster_or_autoscale ? length(var.network_security_group_node_ingress) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_node_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = var.network_security_group_node_ingress[count.index].protocol
  description               = var.network_security_group_node_ingress[count.index].description
  source                    = var.network_security_group_node_ingress[count.index].source
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  dynamic "tcp_options" {
    for_each = var.network_security_group_node_ingress[count.index].protocol == 6 ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_node_ingress[count.index].port_min
        max = var.network_security_group_node_ingress[count.index].port_max
      }
    }
  }
  dynamic "udp_options" {
    for_each = var.network_security_group_node_ingress[count.index].protocol == 17 ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_node_ingress[count.index].port_min
        max = var.network_security_group_node_ingress[count.index].port_max
      }
    }
  }
  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

# Network Security group for Kafka server
resource "oci_core_network_security_group" "red5pro_kafka_network_security_group" {
  count          = local.kafka_standalone_instance ? 1 : 0
  compartment_id = var.oracle_compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.name}-kafka-nsg"
}

resource "oci_core_network_security_group_security_rule" "red5pro_kafka_nsg_security_rule_ingress" {
  count                     = local.kafka_standalone_instance ? length(var.network_security_group_kafka_ingress) : 0
  network_security_group_id = oci_core_network_security_group.red5pro_kafka_network_security_group[0].id
  direction                 = "INGRESS"
  protocol                  = var.network_security_group_kafka_ingress[count.index].protocol
  description               = var.network_security_group_kafka_ingress[count.index].description
  source                    = var.network_security_group_kafka_ingress[count.index].source
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  dynamic "tcp_options" {
    for_each = var.network_security_group_kafka_ingress[count.index].protocol == 6 ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_kafka_ingress[count.index].port_min
        max = var.network_security_group_kafka_ingress[count.index].port_max
      }
    }
  }
  dynamic "udp_options" {
    for_each = var.network_security_group_kafka_ingress[count.index].protocol == 17 ? [1] : []
    content {
      destination_port_range {
        min = var.network_security_group_kafka_ingress[count.index].port_min
        max = var.network_security_group_kafka_ingress[count.index].port_max
      }
    }
  }
  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}
