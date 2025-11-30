build {
  name    = "debian-custom-qcow2"
  sources = ["source.qemu.debian-cloud"]

  provisioner "shell" {
    inline = [
      "set -eux",
      "cloud-init status --wait",
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    inline = [
      "set -eux",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl vim htop qemu-guest-agent",
    ]
  }


  provisioner "shell" {
    inline = [
      "set -eux",

      # cloud-init: clean instance state so Proxmox cloud-init treats it as fresh
      "sudo cloud-init clean --logs",
      "sudo rm -rf /var/lib/cloud/*",

      # reset machine-id so each clone gets a unique one
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",

      # remove SSH host keys so they regenerate on first boot
      "sudo rm -f /etc/ssh/ssh_host_*",

      # scrub logs/tmp (optional, but nice)
      "sudo rm -rf /var/log/* /var/tmp/* /tmp/* || true",
    ]
  }

  provisioner "shell" {
    inline = [
      "set -eux",

      # drop from sudo and sudoers
      "sudo deluser ${var.username} sudo",
      "sudo rm /etc/sudoers.d/${var.username}",
      "sudo rm /etc/sudoers.d/90-cloud-init-users",
      "sudo sed -i '/^${var.username} ALL=.*/d' /etc/sudoers || true",

      # remove SSH keys and history
      "sudo rm -rf /home/${var.username}/.ssh || true",
      "sudo rm -f /home/${var.username}/.bash_history || true",


      # disable interactive shell
      "if [ -x /usr/sbin/nologin ]; then",
      "  sudo usermod -s /usr/sbin/nologin ${var.username} || true",
      "else",
      "  sudo usermod -s /bin/false ${var.username} || true",
      "fi",

      # wipe home contents but keep dir
      "find /home/${var.username} -mindepth 1 -maxdepth 1 -exec rm -rf {} +",

      # lock + expire account
      "sudo usermod -Le 1  ${var.username}",
    ]
  }

  post-processor "shell-local" {
    inline = [
      "set -eux",
      "mv ${var.output_directory}/packer-debian-cloud ${var.output_directory}/${var.image_name}.qcow2",
      "qemu-img info ${var.output_directory}/${var.image_name}.qcow2",
    ]
  }
}
