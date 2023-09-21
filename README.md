# Oracle Cloud(OCI) Red5 Pro Terraform module

Terraform Red5 Pro Oracle Cloud(OCI) module for Red5 Pro resources.

## This module has 3 variants of Red5 Pro deployments

* **single** - Single instance with installed and configured Red5 Pro server
* **cluster** - Stream Manager cluster (MySQL DB + Stream Manager instance + Autoscaling Node group with Origin, Edge, Transcoder, Relay instances)
* **autoscaling** - Autoscaling Stream Managers (MySQL Oracle Cloud MySQL DB System  + Load Balancer + Autoscaling Stream Managers + Autoscaling Node group with Origin, Edge, Transcoder, Relay instances)


## Preparation

* Install **terraform** https://registry.terraform.io/providers/oracle/oci/latest/docs
* Install **OCI CLI** https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm
* Install **jq** Linux or Mac OS only - `apt install jq` or `brew install jq` (It is using in bash scripts to create/delete Stream Manager node group using API)
* Download Red5 Pro server build: (Example: red5pro-server-0.0.0.b0-release.zip) https://account.red5pro.com/downloads
* Download Red5 Pro Autoscale controller for Terraform: (Example: terraform-cloud-controller-0.0.0.jar) https://account.red5pro.com/downloads
* Download Red5 Pro Terraform Service : (Example: terraform-service-0.0.0.zip) https://account.red5pro.com/downloads
* Get Red5 Pro License key: (Example: 1111-2222-3333-4444) https://account.red5pro.com
* Prepare Oracle Cloud access user for Terraform
    * Identity and Access Management Rights (management access rights)
        * Virtual Cloud Networks
        * Compute Instances
        * Instance Configurations
        * Autoscaling Configurations
        * Load balancers
        * MySQL DB Systems 
        * OCI Certificates
    * Generate API keys for Oracle Cloud user(Required for Oracle Cloud CLI support)
        * Follow the documentation for generating keys on OCI Documentation - https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two
    * Upload your API keys to Oracle Cloud 
        * Follow the documentation for uploading your keys on OCI Documentation - https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two
        * After uploading the keys to Oracle Cloud, get API key's fingerprint displayed (for example, 12:34:56:78:90:ab:cd:ef:12:34:56:78:90:ab:cd:ef)
    * Create an OCI compartment for creating resources in Oracle Cloud Account 
        * Follow the documentation for creating a compartment - https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm#two
    * Get the necessary OCIDs from Oracle Cloud Account
        * Compartment OCID 
        * Tenancy OCID
        * User OCID
    * Authenticating OCI CLI
        * Token-based Authentication for the OCI CLI - https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitoken.htm
        * Custom OCI CLI Configuration(Override the Default Configuration) - https://www.ateam-oracle.com/post/oracle-cloud-infrastructure-cli-scripting-how-to-quickly-override-the-default-configuration
* Copy Red5 Pro server build, Autoscale controller for Terraform and Terraform Service to the root folder of your project

Example:  

```bash
cp ~/Downloads/red5pro-server-0.0.0.b0-release.zip ./
cp ~/Downloads/terraform-cloud-controller-0.0.0.jar ./
cp ~/Downloads/terraform-service-0.0.0.zip ./
```

## Red5 Pro Single server deployment (single) - [Example](https://github.com/red5pro/terraform-oci-red5pro/tree/main/examples/single)

* VCN create or use existing
* Security group create or use existing
* SSL certificate install Let's encrypt or use Red5Pro server without SSL certificate (HTTP only)

```hcl
module "red5pro_single" {
  source                = "../../"
  type                  = "single"                                # Deployment type: single, cluster, autoscaling
  name                  = "red5pro-single"                        # Name to be used on all the resources as identifier
  path_to_red5pro_build = "./red5pro-server-0.0.0.b0-release.zip" # Absolute path or relative path to Red5 Pro server ZIP file

  # Oracle Cloud Account Details
  compartment_id = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Existing Compartment OCID of Oracle Cloud Account

  # SSH key configuration
  ssh_private_key_path = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_pri_key.pem" # Path to existing SSH private key
  ssh_public_key_path  = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_pub_key.pem" # Path to existing SSH Public key

  # VCN Configuration
  vcn_create           = true                                                                                # true - create new VCN, false - use existing VCN
  vcn_id_existing      = "ocid1.vcn.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"    # VCN OCID for existing VCN Network
  vcn_name_existing    = "red5pro-single-vcn"                                                                # VCN name for existing VCN Network
  vcn_dns_label        = "vcnexample"                                                                        # Should contains chanraters only for VCN DNS Labels, No special characters and white spaces allowed                                        
  subnet_id_existing   = "ocid1.subnet.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Subnet OCID for existing VCN Subnet
  subnet_name_existing = "red5pro-single-public-subnet"                                                      # Subnet name for existing VCN Subnet

  # Network Security Group configuration
  network_security_group_create      = true         # true - create new Network Security Group, false - use existing Network Security Group
  network_security_group_id_existing = "sg-example" # Network Security Group ID for existing security group

  # Single Red5 Pro server HTTPS/SSL certificate configuration
  https_letsencrypt_enable                  = true                  # true - create new Let's Encrypt HTTPS/SSL certificate, false - use Red5 Pro server without HTTPS/SSL certificate
  https_letsencrypt_certificate_domain_name = "red5pro.example.com" # Domain name for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_email       = "email@example.com"   # Email for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_password    = "examplepass"         # Password for Let's Encrypt SSL certificate

  # Single Red5 Pro server OCI instance configuration
  single_instance_type = "VM.Standard.E4.Flex" # Instance type for Red5 Pro server
  single_volume_size   = 8                     # Volume size for Red5 Pro server

  # Red5Pro server configuration
  red5pro_license_key                         = "1111-2222-3333-4444"         # Red5 Pro license key (https://account.red5pro.com/login)
  red5pro_api_enable                          = true                          # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5pro.com/docs/development/api/overview/)
  red5pro_api_key                             = "examplekey"                  # Red5 Pro server API key (https://www.red5pro.com/docs/development/api/overview/)
  red5pro_inspector_enable                    = false                         # true - enable Red5 Pro server inspector, false - disable Red5 Pro server inspector (https://www.red5pro.com/docs/troubleshooting/inspector/overview/)
  red5pro_restreamer_enable                   = false                         # true - enable Red5 Pro server restreamer, false - disable Red5 Pro server restreamer (https://www.red5pro.com/docs/special/restreamer/overview/)
  red5pro_socialpusher_enable                 = false                         # true - enable Red5 Pro server socialpusher, false - disable Red5 Pro server socialpusher (https://www.red5pro.com/docs/special/social-media-plugin/overview/)
  red5pro_suppressor_enable                   = false                         # true - enable Red5 Pro server suppressor, false - disable Red5 Pro server suppressor
  red5pro_hls_enable                          = false                         # true - enable Red5 Pro server HLS, false - disable Red5 Pro server HLS (https://www.red5pro.com/docs/protocols/hls-plugin/hls-vod/)
  red5pro_round_trip_auth_enable              = false                         # true - enable Red5 Pro server round trip authentication, false - disable Red5 Pro server round trip authentication (https://www.red5pro.com/docs/special/round-trip-auth/overview/)
  red5pro_round_trip_auth_host                = "round-trip-auth.example.com" # Round trip authentication server host
  red5pro_round_trip_auth_port                = 3000                          # Round trip authentication server port
  red5pro_round_trip_auth_protocol            = "http"                        # Round trip authentication server protocol
  red5pro_round_trip_auth_endpoint_validate   = "/validateCredentials"        # Round trip authentication server endpoint for validate
  red5pro_round_trip_auth_endpoint_invalidate = "/invalidateCredentials"      # Round trip authentication server endpoint for invalidate
}

output "module_output" {
  value = module.red5pro_single
}
```

---

## Red5 Pro Stream Manager cluster deployment (cluster) - [Example](https://github.com/red5pro/terraform-oci-red5pro/tree/main/examples/cluster)

* VCN create or use existing
* Network Security groups will be created automatically or user existing (Stream Manager, Terraform Service, Nodes, MySQL DB System and others)
* MySQL DB create in Oracle Cloud MySQL DB System or install it locally on the Stream Manager
* Create a dedicated OCI instance for Terraform Server or install it locally on the Stream Manager
* Stream Manager instance will be created automatically
* SSL certificate install Let's encrypt or use Red5 Pro Stream Manager without SSL certificate (HTTP only)
* Origin node image create
* Edge node image create or not (it is optional)
* Transcoder node image create or not (it is optional)
* Relay node image create or not (it is optional)
* Autoscaling node group using API to Stream Manager (optional) - (https://www.red5pro.com/docs/special/concepts/nodegroup/)

```hcl
module "red5pro_stream_manager" {
  source                                = "../../"
  type                                  = "cluster"                                # Deployment type: single, cluster, autoscaling
  name                                  = "red5pro-cluster"                        # Name to be used on all the resources as identifier
  path_to_red5pro_build                 = "./red5pro-server-0.0.0.b0-release.zip"  # Absolute path or relative path to Red5 Pro server ZIP file
  path_to_terraform_cloud_controller    = "./terraform-cloud-controller-0.0.0.jar" # Absolute path or relative path to Terraform Cloud Controller JAR file
  path_to_terraform_service_build       = "./terraform-service-0.0.0.zip"
  path_to_private_key_terraform_service = "./example_pri_key.pem"
  path_to_public_key_terraform_service  = "./example_pub_key.pem"

  # Oracle Cloud Account Details
  compartment_id = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Existing Compartment OCID of Oracle Cloud Account
  tenancy_ocid   = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"     # Existing Tenancy OCID of Oracle Cloud Account
  user_ocid      = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"        # Existing User OCID of Oracle Cloud Account
  fingerprint    = "00:11:22:33:44:55:66:77:aa:bb:cc:dd:ee:ff:gg:hh"                                     # Existing SSH based API key fingerprint of Oracle Cloud Account
  region         = "us-ashburn-1"                                                                        # Current region code name of Oracle Cloud Account, https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

  # SSH key configuration
  ssh_private_key_path = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_pri_key.pem" # Path to existing SSH private key
  ssh_public_key_path  = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_pub_key.pem" # Path to existing SSH Public key

  # VCN Configuration
  vcn_create           = true                                                                                # true - create new VCN, false - use existing VCN
  vcn_id_existing      = "ocid1.vcn.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"    # VCN OCID for existing VCN Network
  vcn_name_existing    = "red5pro-cluster-vcn"                                                               # VCN name for existing VCN Network
  vcn_dns_label        = "vcnexample"                                                                        # Should contains chanraters only for VCN DNS Labels, No special characters and white spaces allowed                                        
  subnet_id_existing   = "ocid1.subnet.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Subnet OCID for existing VCN Subnet
  subnet_name_existing = "red5pro-cluster-public-subnet"                                                     # Subnet name for existing VCN Subnet

  # Network Security Group configuration
  network_security_group_create      = true                                                                                              # true - create new Network Security Group, false - use existing Network Security Group
  network_security_group_id_existing = "ocid1.networksecuritygroup.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Network Security Group OCID for existing Network Security Group

  # MySQL DB configuration
  mysql_db_system_create         = false                        # true - create new Oracle Cloud MySQL DB System  instance, false - install local MySQL server on the Stream Manager OCI instance
  mysql_shape_name               = "MySQL.VM.Standard.E3.1.8GB" # Instance type for Oracle Cloud MySQL DB system instance
  mysql_db_system_admin_username = "smadmin"                    # MySQL admin username
  mysql_db_system_admin_password = "mY5QLp@55W4rDABC123"        # MySQL admin password
  mysql_user_name                = "exampleuser"                # MySQL username
  mysql_password                 = "examplepass"                # MySQL password
  mysql_port                     = 3306                         # MySQL port

  # Terraform Service configuration
  dedicated_terra_host_create = true
  terra_api_token             = "abc123"
  terra_parallelism           = "20"

  # Stream Manager HTTPS/SSL certificate configuration
  https_letsencrypt_enable                  = true                  # true - create new Let's Encrypt HTTPS/SSL certificate, false - use Red5 Pro server without HTTPS/SSL certificate
  https_letsencrypt_certificate_domain_name = "red5pro.example.com" # Domain name for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_email       = "email@example.com"   # Email for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_password    = "examplepass"         # Password for Let's Encrypt SSL certificate

  # Stream Manager configuration
  stream_manager_instance_type   = "VM.Standard.E4.Flex" # OCI Instance type for Stream Manager
  stream_manager_instance_cpu    = 2                     # OCI Instance OCPU Count for Stream Manager(1 OCPU = 2 vCPU)
  stream_manager_instance_memory = 8                     # OCI Instance Memory size in GB for Stream Manager
  stream_manager_api_key         = "examplekey"          # API key for Stream Manager

  # Red5 Pro general configuration
  red5pro_license_key = "1111-2222-3333-4444" # Red5 Pro license key (https://account.red5pro.com/login)
  red5pro_cluster_key = "examplekey"          # Red5 Pro cluster key
  red5pro_api_enable  = true                  # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5pro.com/docs/development/api/overview/)
  red5pro_api_key     = "examplekey"          # Red5 Pro server API key (https://www.red5pro.com/docs/development/api/overview/)

  # Red5 Pro autoscaling Origin node image configuration
  origin_image_create                                      = true                          # Default: true for Autoscaling and Cluster, true - create new Origin node image, false - not create new Origin node image
  origin_image_instance_type                               = "VM.Standard.E4.Flex"         # Instance type for Origin node image
  origin_image_instance_cpu                                = 2                             # OCI Instance OCPU Count for Origin node image(1 OCPU = 2 vCPU)
  origin_image_instance_memory                             = 4                             # OCI Instance Memory size in GB for Origin node image
  origin_image_volume_size                                 = 16                            # Volume size for Origin node image
  origin_image_red5pro_inspector_enable                    = false                         # true - enable Red5 Pro server inspector, false - disable Red5 Pro server inspector (https://www.red5pro.com/docs/troubleshooting/inspector/overview/)
  origin_image_red5pro_restreamer_enable                   = false                         # true - enable Red5 Pro server restreamer, false - disable Red5 Pro server restreamer (https://www.red5pro.com/docs/special/restreamer/overview/)
  origin_image_red5pro_socialpusher_enable                 = false                         # true - enable Red5 Pro server socialpusher, false - disable Red5 Pro server socialpusher (https://www.red5pro.com/docs/special/social-media-plugin/overview/)
  origin_image_red5pro_suppressor_enable                   = false                         # true - enable Red5 Pro server suppressor, false - disable Red5 Pro server suppressor
  origin_image_red5pro_hls_enable                          = false                         # true - enable Red5 Pro server HLS, false - disable Red5 Pro server HLS (https://www.red5pro.com/docs/protocols/hls-plugin/hls-vod/)
  origin_image_red5pro_round_trip_auth_enable              = false                         # true - enable Red5 Pro server round trip authentication, false - disable Red5 Pro server round trip authentication (https://www.red5pro.com/docs/special/round-trip-auth/overview/)
  origin_image_red5pro_round_trip_auth_host                = "round-trip-auth.example.com" # Round trip authentication server host
  origin_image_red5pro_round_trip_auth_port                = 3000                          # Round trip authentication server port
  origin_image_red5pro_round_trip_auth_protocol            = "http"                        # Round trip authentication server protocol
  origin_image_red5pro_round_trip_auth_endpoint_validate   = "/validateCredentials"        # Round trip authentication server endpoint for validate
  origin_image_red5pro_round_trip_auth_endpoint_invalidate = "/invalidateCredentials"      # Round trip authentication server endpoint for invalidate

  # Red5 Pro autoscaling Node group - (Optional)
  node_group_create = true                   # Linux or Mac OS only. true - create new Node group, false - not create new Node group
  node_group_name   = "terraform-node-group" # Node group name
  # Origin node configuration
  node_group_origins               = 1                         # Number of Origins
  node_group_origins_instance_type = "VM.Standard.E4.Flex-1-4" # Origins OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_origins_capacity      = 30                        # Connections capacity for Origins
  # Edge node configuration
  node_group_edges               = 1                         # Number of Edges
  node_group_edges_instance_type = "VM.Standard.E4.Flex-1-4" # Edges OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_edges_capacity      = 300                       # Connections capacity for Edges
  # Transcoder node configuration
  node_group_transcoders               = 0                         # Number of Transcoders
  node_group_transcoders_instance_type = "VM.Standard.E4.Flex-1-4" # Transcoders OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_transcoders_capacity      = 30                        # Connections capacity for Transcoders
  # Relay node configuration
  node_group_relays               = 0                         # Number of Relays
  node_group_relays_instance_type = "VM.Standard.E4.Flex-1-4" # Relays OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_relays_capacity      = 30                        # Connections capacity for Relays
}

output "module_output" {
  value = module.red5pro_stream_manager
}
```

---

## Red5 Pro Stream Manager cluster with Oracle Cloud autoscaling Stream Managers (autoscaling) - [Example](https://github.com/red5pro/terraform-oci-red5pro/tree/main/examples/autoscaling)
* VCN create or use existing
* Network Security groups will be created automatically or user existing (Stream Manager, Terraform Service, Nodes, MySQL DB System and others)
* MySQL DB will be created automaticaly in Oracle Cloud MySQL DB System 
* Create a dedicated OCI instance for Terraform Server
* Create SSL certificate using CA certificate authority files
* Load Balancer for Stream Managers will be created automatically
* Autoscaling configuration for Stream Managers will be created automatically
* Stream Manager image will be created automatically
* Instance configuration for Stream Managers will be created automatically
* Origin node image create or not (it is optional)
* Edge node image create or not (it is optional)
* Transcoder node image create or not (it is optional)
* Relay node image create or not (it is optional)
* Autoscaling node group using API to Stream Manager (optional) - (https://www.red5pro.com/docs/special/concepts/nodegroup/)

```hcl
module "red5pro_stream_manager" {
  source                                = "../../"
  type                                  = "autoscaling"                            # Deployment type: single, cluster, autoscaling
  name                                  = "red5pro-autoscaling"                    # Name to be used on all the resources as identifier
  path_to_red5pro_build                 = "./red5pro-server-0.0.0.b0-release.zip"  # Absolute path or relative path to Red5 Pro server ZIP file
  path_to_terraform_cloud_controller    = "./terraform-cloud-controller-0.0.0.jar" # Absolute path or relative path to Terraform Cloud Controller JAR file
  path_to_terraform_service_build       = "./terraform-service-0.0.0.zip"
  path_to_private_key_terraform_service = "./example_pri_key.pem"
  path_to_public_key_terraform_service  = "./example_pub_key.pem"

  # Oracle Cloud Account Details
  compartment_id = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Existing Compartment OCID of Oracle Cloud Account
  tenancy_ocid   = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"     # Existing Tenancy OCID of Oracle Cloud Account
  user_ocid      = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"        # Existing User OCID of Oracle Cloud Account
  fingerprint    = "00:11:22:33:44:55:66:77:aa:bb:cc:dd:ee:ff:gg:hh"                                     # Existing SSH based API key fingerprint of Oracle Cloud Account
  region         = "us-ashburn-1"                                                                        # Current region code name of Oracle Cloud Account, https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

  # SSH key configuration
  ssh_private_key_path = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_pri_key.pem" # Path to existing SSH private key
  ssh_public_key_path  = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_pub_key.pem" # Path to existing SSH Public key

  # VCN Configuration
  vcn_create           = true                                                                                # true - create new VCN, false - use existing VCN
  vcn_id_existing      = "ocid1.vcn.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"    # VCN OCID for existing VCN Network
  vcn_name_existing    = "red5pro-autoscaling-vcn"                                                               # VCN name for existing VCN Network
  vcn_dns_label        = "vcnexample"                                                                        # Should contains chanraters only for VCN DNS Labels, No special characters and white spaces allowed                                        
  subnet_id_existing   = "ocid1.subnet.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Subnet OCID for existing VCN Subnet
  subnet_name_existing = "red5pro-autoscaling-public-subnet"                                                     # Subnet name for existing VCN Subnet

  # Network Security Group configuration
  network_security_group_create      = true                                                                                              # true - create new Network Security Group, false - use existing Network Security Group
  network_security_group_id_existing = "ocid1.networksecuritygroup.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Network Security Group OCID for existing Network Security Group

  # MySQL DB configuration
  mysql_db_system_create         = false                        # true - create new MySQL DB System instance, false - install local MySQL server on the Stream Manager OCI instance
  mysql_shape_name               = "MySQL.VM.Standard.E3.1.8GB" # Instance type for Oracle Cloud MySQL DB system instance
  mysql_db_system_admin_username = "smadmin"                    # MySQL admin username
  mysql_db_system_admin_password = "mY5QLp@55W4rDABC123"        # MySQL admin password
  mysql_user_name                = "exampleuser"                # MySQL username
  mysql_password                 = "examplepass"                # MySQL password
  mysql_port                     = 3306                         # MySQL port

  # Terraform Service configuration
  dedicated_terra_host_create = true
  terra_api_token             = "abc123"
  terra_parallelism           = "20"

  # Stream Manager Reserved IP Address configuration
  elastic_ip_create       = true                                              # true - create new Reserved IP, false - use existing Reserved IP
  elastic_ip_existing     = "1.2.3.4"                                         # Reserved IP Address for existing Oracle Cloud Reserved IP

  # Load Balancer HTTPS/SSL certificate configuration
  https_oci_certificates_use_existing     = false                # If you want to use SSL certificate set it to true
  https_oci_certificates_certificate_name = "rk-ops.red5pro.net" # Domain name for your SSL certificate
  cert_fullchain   = "D:/BrittonDevOps/SCM/GitHub/terraform-oci-red5pro/certs/wildcard_cert_red5pro.net/fullchain.pem"
  cert_private_key = "D:/BrittonDevOps/SCM/GitHub/terraform-oci-red5pro/certs/wildcard_cert_red5pro.net/privkey.pem"
  cert_public_cert = "D:/BrittonDevOps/SCM/GitHub/terraform-oci-red5pro/certs/wildcard_cert_red5pro.net/cert.pem"

  # Stream Manager configuration
  stream_manager_instance_type   = "VM.Standard.E4.Flex" # OCI Instance type for Stream Manager
  stream_manager_instance_cpu    = 2                     # OCI Instance OCPU Count for Stream Manager(1 OCPU = 2 vCPU)
  stream_manager_instance_memory = 4                     # OCI Instance Memory size in GB for Stream Manager
  stream_manager_api_key         = "examplekey"          # API key for Stream Manager

  # Red5 Pro general configuration
  red5pro_license_key = "1111-2222-3333-4444" # Red5 Pro license key (https://account.red5pro.com/login)
  red5pro_cluster_key = "examplekey"          # Red5 Pro cluster key
  red5pro_api_enable  = true                  # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5pro.com/docs/development/api/overview/)
  red5pro_api_key     = "examplekey"          # Red5 Pro server API key (https://www.red5pro.com/docs/development/api/overview/)

  # Red5 Pro autoscaling Origin node image configuration
  origin_image_create                                      = true                          # Default: true for Autoscaling and Cluster, true - create new Origin node image, false - not create new Origin node image
  origin_image_instance_type                               = "VM.Standard.E4.Flex"         # Instance type for Origin node image
  origin_image_instance_cpu                                = 2                             # OCI Instance OCPU Count for Origin node image(1 OCPU = 2 vCPU)
  origin_image_instance_memory                             = 4                             # OCI Instance Memory size in GB for Origin node image
  origin_image_volume_size                                 = 8                             # Volume size for Origin node image
  origin_image_red5pro_inspector_enable                    = false                         # true - enable Red5 Pro server inspector, false - disable Red5 Pro server inspector (https://www.red5pro.com/docs/troubleshooting/inspector/overview/)
  origin_image_red5pro_restreamer_enable                   = false                         # true - enable Red5 Pro server restreamer, false - disable Red5 Pro server restreamer (https://www.red5pro.com/docs/special/restreamer/overview/)
  origin_image_red5pro_socialpusher_enable                 = false                         # true - enable Red5 Pro server socialpusher, false - disable Red5 Pro server socialpusher (https://www.red5pro.com/docs/special/social-media-plugin/overview/)
  origin_image_red5pro_suppressor_enable                   = false                         # true - enable Red5 Pro server suppressor, false - disable Red5 Pro server suppressor
  origin_image_red5pro_hls_enable                          = false                         # true - enable Red5 Pro server HLS, false - disable Red5 Pro server HLS (https://www.red5pro.com/docs/protocols/hls-plugin/hls-vod/)
  origin_image_red5pro_round_trip_auth_enable              = false                         # true - enable Red5 Pro server round trip authentication, false - disable Red5 Pro server round trip authentication (https://www.red5pro.com/docs/special/round-trip-auth/overview/)
  origin_image_red5pro_round_trip_auth_host                = "round-trip-auth.example.com" # Round trip authentication server host
  origin_image_red5pro_round_trip_auth_port                = 3000                          # Round trip authentication server port
  origin_image_red5pro_round_trip_auth_protocol            = "http"                        # Round trip authentication server protocol
  origin_image_red5pro_round_trip_auth_endpoint_validate   = "/validateCredentials"        # Round trip authentication server endpoint for validate
  origin_image_red5pro_round_trip_auth_endpoint_invalidate = "/invalidateCredentials"      # Round trip authentication server endpoint for invalidate

  # Red5 Pro autoscaling Node group - (Optional)
  node_group_create = true                   # Linux or Mac OS only. true - create new Node group, false - not create new Node group
  node_group_name   = "terraform-node-group" # Node group name
  # Origin node configuration
  node_group_origins               = 1                         # Number of Origins
  node_group_origins_instance_type = "VM.Standard.E4.Flex-1-4" # Origins OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_origins_capacity      = 30                        # Connections capacity for Origins
  # Edge node configuration
  node_group_edges               = 1                         # Number of Edges
  node_group_edges_instance_type = "VM.Standard.E4.Flex-1-4" # Edges OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_edges_capacity      = 300                       # Connections capacity for Edges
  # Transcoder node configuration
  node_group_transcoders               = 0                         # Number of Transcoders
  node_group_transcoders_instance_type = "VM.Standard.E4.Flex-1-4" # Transcoders OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_transcoders_capacity      = 30                        # Connections capacity for Transcoders
  # Relay node configuration
  node_group_relays               = 0                         # Number of Relays
  node_group_relays_instance_type = "VM.Standard.E4.Flex-1-4" # Relays OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_relays_capacity      = 30                        # Connections capacity for Relays
}

output "module_output" {
  value = module.red5pro_stream_manager
}
```
**NOTES**

* To activate HTTPS/SSL you need to add DNS A record for Public IP address and access the Red5 Pro servers with domain name(single/cluster/autoscaling).

## Future updates
* TBD
