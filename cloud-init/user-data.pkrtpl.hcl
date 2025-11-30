#cloud-config
users:
  - name: ${build_username}
    uid: 9999
    groups:
      - sudo
    shell: /bin/bash
    lock_passwd: false
    plain_text_passwd: ${build_password}
    sudo: ALL=(ALL) NOPASSWD:ALL

ssh_pwauth: true
disable_root: true
