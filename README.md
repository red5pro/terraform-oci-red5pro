# Oracle Cloud Infrastructure(OCI) Terraform module for Red5 Pro

[Red5 Pro](https://www.red5.net/) is a real-time video streaming server plaform known for its low-latency streaming capabilities, making it ideal for interactive applications like online gaming, streaming events and video conferencing etc.

This a reusable Terraform installer module for [Red5 Pro](https://www.red5pro.com/docs/installation/auto-oci/overview/) that provisions infrastucture over [Oracle Cloud Infrastructure(OCI)](https://www.oracle.com/cloud/).

## This module has 3 variants of Red5 Pro deployments

* **single** - Single instance with installed and configured Red5 Pro server
* **cluster** - Stream Manager cluster (MySQL DB + Stream Manager instance + Autoscaling Node group with Origin, Edge, Transcoder, Relay instances)
* **autoscaling** - Autoscaling Stream Managers (MySQL Oracle Cloud MySQL DB System  + Load Balancer + Autoscaling Stream Managers + Autoscaling Node group with Origin, Edge, Transcoder, Relay instances)

## Preparation

* Install **terraform** https://developer.hashicorp.com/terraform/downloads
  * Open your web browser and visit the [Terraform download page](https://developer.hashicorp.com/terraform/downloads), ensuring you get version 1.0.0 or higher. 
  * Download the suitable version for your operating system, 
  * Extract the compressed file, and then copy the Terraform binary to a location within your system's path
    * Configure path on Linux/macOS 
      * Open a terminal and type the following:

        ```$ sudo mv /path/to/terraform /usr/local/bin```
    * Configure path on Windows OS
      * Click 'Start', search for 'Control Panel', and open it.
      * Navigate to System > Advanced System Settings > Environment Variables.
      * Under System variables, find 'PATH' and click 'Edit'.
      * Click 'New' and paste the directory location where you extracted the terraform.exe file.
      * Confirm changes by clicking 'OK' and close all open windows.
      * Open a new terminal and verify that Terraform has been successfully installed.

* Install **Authenticating Oracle Cloud Infrastructure(OCI) CLI** https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm
* Install **jq** Linux or Mac OS only - `apt install jq` or `brew install jq` (It is used in bash scripts to create/delete Stream Manager node group using API) https://jqlang.github.io/jq/download/
* Download Red5 Pro server build: (Example: red5pro-server-0.0.0.b0-release.zip) https://account.red5pro.com/downloads
* Download Red5 Pro Autoscale controller for Terraform: (Example: terraform-cloud-controller-0.0.0.jar) https://account.red5pro.com/downloads
* Download Red5 Pro Terraform Service : (Example: terraform-service-0.0.0.zip) https://account.red5pro.com/downloads
* Get Red5 Pro License key: (Example: 1111-2222-3333-4444) https://account.red5pro.com
* Prepare [Oracle Cloud Infrastructure(OCI)](https://www.oracle.com/cloud/) Account and create a User for Terraform module. User must have permission to create and manage the following services:
    * Identity and Access Management Rights
        * Virtual Cloud Networks
        * Compute Instances
        * Instance Configurations
        * Autoscaling Configurations
        * Load balancers
        * MySQL DB Systems 
        * OCI Certificates
    * Generate API keys for Oracle Cloud Infrastructure(OCI) user(Required for Oracle Cloud CLI support)
        * Follow the documentation for generating keys on OCI Documentation - https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two
    * Upload your API keys to Oracle Cloud Infrastructure(OCI)
        * Follow the documentation for uploading your keys on OCI Documentation - https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two
        * After uploading the keys to Oracle Cloud, get API key's fingerprint displayed (for example, `12:34:56:78:90:11:cd:ef:12:34:56:78:90:ba:cd:ef`)
    * Create an OCI compartment for creating resources in Oracle Cloud Infrastructure(OCI) Account 
        * Follow the documentation for creating a compartment - https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm#two
    * Get the necessary OCIDs from Oracle Cloud Infrastructure(OCI) Account
        * Compartment OCID 
        * Tenancy OCID
        * User OCID
    * Authenticating Oracle Cloud Infrastructure(OCI) CLI
        * Token-based Authentication for the Authenticating Oracle Cloud Infrastructure(OCI) CLI - https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitoken.htm
        * Custom Authenticating Oracle Cloud Infrastructure(OCI) CLI Configuration(Override the Default Configuration) - https://www.ateam-oracle.com/post/oracle-cloud-infrastructure-cli-scripting-how-to-quickly-override-the-default-configuration
* Copy Red5 Pro server build, Autoscale controller for Terraform and Terraform Service to the root folder of your project

Example:

```bash
cp ~/Downloads/red5pro-server-0.0.0.b0-release.zip ./
cp ~/Downloads/terraform-cloud-controller-0.0.0.jar ./
cp ~/Downloads/terraform-service-0.0.0.zip ./
```

## Red5 Pro Single server deployment (single) - [Example](https://github.com/red5pro/terraform-oci-red5pro/tree/main/examples/single)

In the following example, Terraform module will automates the infrastructure provisioning of the [Red5 Pro standalone server](https://www.red5pro.com/docs/installation/installation/oci-install/).

* **VCN** - This Terrform module can either create a new or use your existing VCN. If you wish to create a new VCN, set `vcn_create` to `true`, and the script will ignore the other VCN configurations. To use your existing VCN, set `vcn_create` to `false` and include your existing vcn_id, name, dns label, subnet id, and subnet name.
* **Network Security Group** - This Terrform module can either create a new or use your existing Network Security Group in Oracle Cloud Infrastructure(OCI).
* **Instance Type** - Select the instance type based on the usecase from [Oracle Cloud Infrastructure(OCI) Compute Shapes](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)
* **SSL Certificates** - User can install Let's encrypt SSL certificates or use Red5Pro server without SSL certificate (HTTP only).

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

In the following example, Terraform module will automates the infrastructure provisioning of the [Stream Manager cluster on the Oracle Cloud Infrastructure(OCI)](https://www.red5pro.com/docs/installation/auto-oci/overview/).

* **VCN** - This Terrform module can either create a new or use your existing VCN. If you wish to create a new VCN, set `vcn_create` to `true`, and the script will ignore the other VCN configurations. To use your existing VCN, set `vcn_create` to `false` and include your existing vcn_id, name, dns label, subnet id, and subnet name
* **Network Security Group** - This Terrform module can either create a new or use your existing Network Security Group in Oracle Cloud Infrastructure(OCI) for Stream Manager, Terraform Service, Nodes, MySQL DB System and others
* **Instance Type** - Select the instance type based on the usecase from [Oracle Cloud Infrastructure(OCI) Compute Shapes](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)
* **MySQL Database** - Users have flexibility to create a MySQL databse server in Oracle Cloud MySQL DB System or install it locally on the Stream Manager
* **Terraform Server** - Uesrs can choose to create a dedicated Oracle Cloud Infrastructure(OCI) instance for Terraform Server or install it locally on the Stream Manager
* **Stream Manager** - Oracle Cloud Infrastructure(OCI) instance will be created automatically for Stream Manager
* **SSL Certificates** - User can install Let's encrypt SSL certificates or use Red5 Pro Stream Manager without SSL certificate (HTTP only)
* **Origin Node Image** - To create Oracle Cloud Infrastructure(OCI) custom image for Orgin Node type for Stream Manager node group
* **Edge Node Image** - To create Oracle Cloud Infrastructure(OCI) custom image for Edge Node type for Stream Manager node group (optional)
* **Transcoder Node Image** - To create Oracle Cloud Infrastructure(OCI) custom image for Transcoder Node type for Stream Manager node group (optional)
* **Relay Node Image** - To create Oracle Cloud Infrastructure(OCI) custom image for Relay Node type for Stream Manager node group (optional)
* **Autoscaling Node Group** - This is required for creating autoscaling node group using [Stream Manager APIs](https://www.red5pro.com/docs/special/concepts/nodegroup/) automatically as part of Terraform module, If users are not selecting this option then they must create a new node group using [Stream Manager APIs](https://www.red5pro.com/docs/special/concepts/nodegroup/) Manually.

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

In the following example, Terraform module will automates the infrastructure provisioning of the [Stream Manager cluster with autoscaling and loadbalancer on the Oracle Cloud Infrastructure(OCI)](https://www.red5pro.com/docs/installation/auto-oci/overview/).

* **VCN** - This Terrform module can either create a new or use your existing VCN. If you wish to create a new VCN, set `vcn_create` to `true`, and the script will ignore the other VCN configurations. To use your existing VCN, set `vcn_create` to `false` and include your existing vcn_id, name, dns label, subnet id, and subnet name
* **Network Security Group** - This Terrform module can either create a new or use your existing Network Security Group in Oracle Cloud Infrastructure(OCI) for Stream Manager, Terraform Service, Nodes, MySQL DB System and others
* **Instance Type** - Select the instance type based on the usecase from [Oracle Cloud Infrastructure(OCI) Compute Shapes](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)
* **MySQL Database** - Users need to create a MySQL databse server in Oracle Cloud MySQL DB System
* **Terraform Server** - Uesrs can choose to create a dedicated Oracle Cloud Infrastructure(OCI) instance for Terraform Server
* **Stream Manager OCI Custom Image** - Oracle Cloud Infrastructure(OCI) custom image will be created automatically for Stream Manager
* **Load Balancer** - Oracle Cloud Infrastructure(OCI) load balancer for Stream Managers will be created automatically
* **Autoscaling Configuration** - Oracle Cloud Infrastructure(OCI) autoscaling configuration for Stream Managers will be created automatically
* **Instance Configuration** - Oracle Cloud Infrastructure(OCI) instance configuration for Stream Managers will be created automatically
* **SSL Certificates** - Create SSL certificate using CA certificate authority files and upload certificates to OCI Certificates OR use exsting OCI Certificates
* **Origin Node Image** - To create Oracle Cloud Infrastructure(OCI) custom image for Orgin Node type for Stream Manager node group
* **Edge Node Image** - To create Oracle Cloud Infrastructure(OCI) custom image for Edge Node type for Stream Manager node group (optional)
* **Transcoder Node Image** - To create Oracle Cloud Infrastructure(OCI) custom image for Transcoder Node type for Stream Manager node group (optional)
* **Relay Node Image** - To create Oracle Cloud Infrastructure(OCI) custom image for Relay Node type for Stream Manager node group (optional)
* **Autoscaling Node Group** - This is required for creating autoscaling node group using [Stream Manager APIs](https://www.red5pro.com/docs/special/concepts/nodegroup/) automatically as part of Terraform module, If users are not selecting this option then they must create a new node group using [Stream Manager APIs](https://www.red5pro.com/docs/special/concepts/nodegroup/) Manually.

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
  mysql_user_name                = "exampleuser"                # MySQL username
  mysql_password                 = "examplepass"                # MySQL password
  mysql_port                     = 3306                         # MySQL port

  # Terraform Service configuration
  dedicated_terra_host_create = true
  terra_api_token             = "abc123"
  terra_parallelism           = "20"

  # Stream Manager Reserved IP Address configuration
  reserved_public_ip_address_create       = true                                              # true - create new Reserved IP, false - use existing Reserved IP
  reserved_public_ip_address_existing     = "1.2.3.4"                                         # Reserved IP Address for existing Oracle Cloud Reserved IP

  # Load Balancer HTTPS/SSL certificate configuration
  https_oci_certificates_use_existing     = true                  # If you want to use SSL certificate set it to true
  https_oci_certificates_certificate_name = "red5pro.example.com" # Domain name for your SSL certificate
  cert_fullchain   = "/PATH/TO/EXISTING/SSL/CERTS/fullchain.pem"
  cert_private_key = "/PATH/TO/EXISTING/SSL/CERTS/privkey.pem"
  cert_public_cert = "/PATH/TO/EXISTING/SSL/CERTS/cert.pem"

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
