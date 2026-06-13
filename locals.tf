locals {
  ssh_key  = file("/home/admin/terraform_task_3/id_rsa.pub")
  os_image = "ubuntu-2204-lts"
}
