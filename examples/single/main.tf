################################################################################
# Example: Red5 Pro Single server (Oracle Cloud VM Instance)
################################################################################

provider "oci" {
  region           = "us-ashburn-1"
  tenancy_ocid     = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  user_ocid        = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  fingerprint      = "00:11:22:33:44:55:66:77:aa:bb:cc:dd:ee:ff:gg:hh"
  private_key_path = "./example_oracle_private_key.pem"
}

module "red5pro_single" {
  source                = "../../"
  type                  = "single"                                # Deployment type: single, cluster, autoscaling
  name                  = "red5pro-single"                        # Name to be used on all the resources as identifier
  ubuntu_version        = "22.04"                                 # Ubuntu version to be used for machine, it can either be 20.04 or 22.04
  path_to_red5pro_build = "./red5pro-server-0.0.0.b0-release.zip" # Absolute path or relative path to Red5 Pro server ZIP file

  # Oracle Cloud Account Details
  oracle_compartment_id = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Existing Compartment OCID of Oracle Cloud Account

  # SSH key configuration
  ssh_key_create       = true
  ssh_private_key_path = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_pri_key.pem" # Path to existing SSH private key
  ssh_public_key_path  = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_pub_key.pem" # Path to existing SSH Public key

  # VCN Configuration
  vcn_create           = true                                                                                # true - create new VCN, false - use existing VCN
  vcn_id_existing      = "ocid1.vcn.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"    # VCN OCID for existing VCN Network
  subnet_id_existing   = "ocid1.subnet.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Subnet OCID for existing VCN Subnet

  # Network Security Group configuration
  network_security_group_create      = true         # true - create new Network Security Group, false - use existing Network Security Group
  network_security_group_id_existing = "ocid1.networksecuritygroup.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Network Security Group ID for existing security group

  # Single Red5 Pro server HTTPS/SSL certificate configuration
  https_letsencrypt_enable                  = true                  # true - create new Let's Encrypt HTTPS/SSL certificate, false - use Red5 Pro server without HTTPS/SSL certificate
  https_letsencrypt_certificate_domain_name = "red5pro.example.com" # Domain name for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_email       = "email@example.com"   # Email for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_password    = "examplepass"         # Password for Let's Encrypt SSL certificate

  # Single Red5 Pro server OCI instance configuration
  single_instance_type   = "VM.Standard.E4.Flex" # Instance type for Red5 Pro server
  single_instance_ocpu   = 2                   # Instance CPU for Red5 Pro server
  single_instance_memory = 4                   # Instance Memory for Red5 Pro server

  # Red5Pro server configuration
  red5pro_license_key                         = "1111-2222-3333-4444"         # Red5 Pro license key (https://account.red5.net/login)
  red5pro_api_enable                          = true                          # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key                             = "examplekey"                  # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)
  red5pro_inspector_enable                    = false                         # true - enable Red5 Pro server inspector, false - disable Red5 Pro server inspector (https://www.red5.net/docs/troubleshooting/inspector/overview/)
  red5pro_restreamer_enable                   = false                         # true - enable Red5 Pro server restreamer, false - disable Red5 Pro server restreamer (https://www.red5.net/docs/special/restreamer/overview/)
  red5pro_socialpusher_enable                 = false                         # true - enable Red5 Pro server socialpusher, false - disable Red5 Pro server socialpusher (https://www.red5.net/docs/special/social-media-plugin/overview/)
  red5pro_suppressor_enable                   = false                         # true - enable Red5 Pro server suppressor, false - disable Red5 Pro server suppressor
  red5pro_hls_enable                          = false                         # true - enable Red5 Pro server HLS, false - disable Red5 Pro server HLS (https://www.red5.net/docs/protocols/hls-plugin/hls-vod/)
  red5pro_round_trip_auth_enable              = false                         # true - enable Red5 Pro server round trip authentication, false - disable Red5 Pro server round trip authentication (https://www.red5.net/docs/special/round-trip-auth/overview/)
  red5pro_round_trip_auth_host                = "round-trip-auth.example.com" # Round trip authentication server host
  red5pro_round_trip_auth_port                = 3000                          # Round trip authentication server port
  red5pro_round_trip_auth_protocol            = "http"                        # Round trip authentication server protocol
  red5pro_round_trip_auth_endpoint_validate   = "/validateCredentials"        # Round trip authentication server endpoint for validate
  red5pro_round_trip_auth_endpoint_invalidate = "/invalidateCredentials"      # Round trip authentication server endpoint for invalidate
}

output "module_output" {
  value = module.red5pro_single
}
