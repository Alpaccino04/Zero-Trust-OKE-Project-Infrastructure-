# Copyright (c) 2023 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
# Zero-Trust Multi-Tier Platform on OKE — Phase 1: Private cluster provisioning
#

module "oke-quickstart" {
  source = "github.com/oracle-quickstart/terraform-oci-oke-quickstart?ref=0.9.3"

  providers = {
    oci             = oci
    oci.home_region = oci.home_region
  }

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region           = var.region

  # App Name to identify deployment. Used for naming resources.
  app_name = "ZeroTrustOKE"

  # Freeform Tags + Defined Tags. Tags are applied to all resources.
  tag_values = { "freeformTags" = { "Environment" = "Dev", "Project" = "Zero-Trust-OKE", "Owner" = "" }, "definedTags" = {} }

  # Cluster endpoint visibility — private control plane, no public route to the API server.
  # Requires a bastion, VPN, or private-endpoint-aware Cloud Shell to reach kubectl.
  cluster_endpoint_visibility = "Private"

  # Cluster type left at module default (BASIC_CLUSTER). Revisit before Phase 4 —
  # OKE Workload Identity (pod-level IAM auth) requires ENHANCED_CLUSTER.
  # cluster_type = "ENHANCED_CLUSTER"

  # OKE Node Pool 1 arguments
  node_pool_cni_type_1                 = "OCI_VCN_IP_NATIVE" # required for Calico-enforced NetworkPolicy (Phase 3) — cluster CNI follows automatically
  node_pool_autoscaler_enabled_1       = true
  node_pool_initial_num_worker_nodes_1 = 2  # base size for the lab
  node_pool_max_num_worker_nodes_1     = 4  # autoscaling ceiling for Phase 6 load demo
  node_pool_instance_shape_1 = { "instanceShape" = "VM.Standard.E5.Flex", "ocpus" = 2, "memory" = 16 }
  node_pool_boot_volume_size_in_gbs_1  = 60

  # Required when node pool CNI is OCI_VCN_IP_NATIVE — allocates a dedicated pod IP subnet
  create_pod_network_subnet = true

  # VCN for OKE arguments — left at example default, no peering/overlap concerns yet
  vcn_cidr_blocks = "10.22.0.0/16"

  # metrics-server installed manually via Cloud Shell (helm) — private endpoint isn't reachable
  # from local machine's Terraform apply, so this Helm release is managed outside Terraform. See README.
  metrics_server_enabled = false

  image_operating_system_1         = "Oracle Linux"
  image_operating_system_version_1 = "9"
}