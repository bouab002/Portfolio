resource "proxmox_virtual_environment_download_file" "noble_minimal_cloudimg_amd64" {
  for_each     = toset(var.pve_nodes)
  content_type = "import"
  datastore_id = "local"
  node_name    = each.value
  url          = "https://cloud-images.ubuntu.com/minimal/daily/noble/current/noble-minimal-cloudimg-amd64.img"
  file_name    = "noble-minimal-cloudimg-amd64.qcow2"
}