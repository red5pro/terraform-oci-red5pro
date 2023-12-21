
# Oracle Cloud Infrastructure(OCI) Red5 Pro single server

In the following example, Terraform module will automates the infrastructure provisioning of the [Red5 Pro standalone server](https://www.red5.net/docs/installation/installation/oci-install/).

* **VCN** - For single server deployment this Terrform module can either create a new or use your existing VCN. If you wish to create a new VCN, set `vcn_create` to `true`, and the script will ignore the other VCN configurations. To use your existing VCN, set `vcn_create` to `false` and include your existing vcn_id, name, dns label, subnet id, and subnet name.
* **Network Security Group** - For single server deployment this Terrform module can either create a new or use your existing Network Security Group in Oracle Cloud Infrastructure(OCI).
* **Instance Type** - Select the instance type based on the usecase from [Oracle Cloud Infrastructure(OCI) Compute Shapes](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)
* **SSL Certificates** - User can install Let's encrypt SSL certificates or use Red5Pro server without SSL certificate (HTTP only).

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
* Download Red5 Pro server build: (Example: red5pro-server-0.0.0.b0-release.zip) https://account.red5.net/downloads
* Download Red5 Pro Autoscale controller for Terraform: (Example: terraform-cloud-controller-0.0.0.jar) https://account.red5.net/downloads
* Download Red5 Pro Terraform Service : (Example: terraform-service-0.0.0.zip) https://account.red5.net/downloads
* Get Red5 Pro License key: (Example: 1111-2222-3333-4444) https://account.red5.net
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
* Copy Red5 Pro server build to the root folder of your project

Example:  

```bash
cp ~/Downloads/red5pro-server-0.0.0.b0-release.zip ./
```

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Notes

* To activate HTTPS/SSL you need to add DNS A record for Public IP of Red5 Pro server
* Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these resources.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_red5pro_single"></a> [red5pro\_single](#module\_red5pro\_single) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_module_output"></a> [module\_output](#output\_module\_output) | n/a |
| <a name="output_red5pro_server_http_url"></a> [red5pro\_server\_http\_url](#output\_red5pro\_server\_http\_url) | Red5 Pro Server HTTP URL |
| <a name="output_red5pro_server_https_url"></a> [red5pro\_server\_https\_url](#output\_red5pro\_server\_https\_url) | Red5 Pro Server HTTPS URL |
| <a name="output_red5pro_server_ip"></a> [red5pro\_server\_ip](#output\_red5pro\_server\_ip) | Red5 Pro Server IP |
| <a name="output_ssh_private_key_path"></a> [ssh\_private\_key\_path](#output\_ssh\_private\_key\_path) | SSH private key path |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | Oracle Cloud VCN ID |
| <a name="output_vcn_name"></a> [vcn\_name](#output\_vcn\_name) | Oracle Cloud VCN Name |
