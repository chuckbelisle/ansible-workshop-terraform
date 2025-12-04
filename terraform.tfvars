# terraform.tfvars for Ansible Windows Workshop

# Non-secret defaults (safe to commit)
location         = "canadacentral"
rg_name          = "rg-ansible-workshop-CHANGEME"

windows_vm_count = 3
windows_vm_size  = "Standard_B2ms"
ansible_vm_size  = "Standard_B2s"

admin_username   = "labadmin"

# If you want to reuse an existing subnet, put the ID here.
# Otherwise leave it as an empty string to let this module create its own VNet/subnet.
existing_subnet_id = ""

# These should normally be provided by the pipeline as secure variables and
# overridden via -var or -var-file logic. Keep them commented or dummy ONLY.
# admin_password = "CHANGEME-OVERRIDDEN-BY-PIPELINE"
# ssh_public_key = "ssh-rsa AAAA...CHANGEME... workshop key"
