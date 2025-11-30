locals {
  user_data = templatefile("${path.root}/cloud-init/user-data.pkrtpl.hcl", {
    build_username = var.username
    build_password = var.password
  })
}
