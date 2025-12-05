# Ansible Windows Workshop – Terraform Lab

This Terraform configuration spins up a **self-contained lab environment** for the Ansible + Windows workshop:

- 1x **Ansible controller** (Ubuntu)
  - Public IP for SSH
  - Cloud-init installs:
    - Python + pip
    - Ansible
    - `pywinrm`
    - `ansible.windows` and `community.windows` collections
- Nx **Windows Server 2022 VMs** (default 3)
  - Private IPs only
  - WinRM HTTP enabled on port 5985 (lab-only)
  - Firewall rule allowing WinRM from within the virtual network

You can either:
- Let this Terraform stack **create its own VNet + subnet + NSG**, or
- Point it at an **existing subnet** (for example, the subnet created in your previous Terraform workshop).

---

## Files & Structure

```text
ansible-workshop-terraform/
  providers.tf                 # azurerm provider configuration
  variables.tf                 # variables (location, counts, VM sizes, creds, networking)
  main.tf                      # RG, optional VNet/Subnet/NSG, modules for VMs
  outputs.tf                   # Ansible controller IPs, Windows VM IPs
  modules/
    ansible_controller/
      main.tf                  # Linux VM + public IP + NIC
      outputs.tf
      cloud-init-ansible.yaml  # installs Ansible + pywinrm + collections
    windows_vm/
      main.tf                  # Windows Server 2022 VM + WinRM CustomScriptExtension
      outputs.tf
```

---

## Using a New VNet & Subnet (Default Behaviour)

By default, Terraform will **create**:

- A new VNet: `vnet-ansible-workshop` (CIDR `10.50.0.0/16` by default)
- A new subnet: `snet-workshop` (CIDR `10.50.1.0/24` by default)
- An NSG that:
  - Allows WinRM (5985) from the virtual network
  - Allows SSH (22) inbound from anywhere (you can tighten this)
  - Allows RDP (3389) inbound from the workshop subnet

To deploy with the default network:

```bash
terraform init

terraform apply   -var "rg_name=rg-ansible-workshop-charles"   -var "admin_password=YourStr0ngP@ssword1"   -var "ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

After it completes, Terraform will output:

- `ansible_controller_public_ip` – use this to SSH into the controller:
  ```bash
  ssh labadmin@<ansible_controller_public_ip>
  ```
- `windows_vm_private_ips` – list of private IPs for the Windows hosts, which you can drop into your Ansible `inventory/hosts.yml`.


## Using an Existing Subnet (e.g., from your previous workshop)

If you already have a VNet + subnet from another Terraform workshop (for example, the subnet where your storage account or other lab resources live), you can **drop this lab into that subnet** instead of creating a new one.

1. Find the subnet ID you want to use. It will look similar to:

   ```text
   /subscriptions/<sub-id>/resourceGroups/<rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>
   ```

2. Pass it to Terraform via the `existing_subnet_id` variable:

   ```bash
   terraform apply      -var "rg_name=rg-ansible-workshop-charles"      -var "admin_password=YourStr0ngP@ssword1"      -var "ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"      -var "existing_subnet_id=/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet-existing/subnets/snet-existing"
   ```

When `existing_subnet_id` is set:

- The `vnet-ansible-workshop`, `snet-workshop`, and `nsg-ansible-workshop` resources in this module are **not created**.
- The Ansible controller and all Windows VMs are attached directly to the existing subnet you specified.
- You should ensure that:
  - The existing subnet has appropriate **NSGs** to allow:
    - SSH (22) from wherever you’ll connect from
    - WinRM (5985) between the controller and the Windows VMs
  - Any required routing / firewall rules are already in place.


## Windows WinRM Configuration (Lab-Only)

Each Windows VM uses a **Custom Script Extension** to configure WinRM HTTP with Basic auth and allow unencrypted traffic:

- Runs `winrm quickconfig -q`
- Sets:
  - `AllowUnencrypted = true`
  - `Basic = true`
- Adds a firewall rule to allow TCP 5985 inbound

This configuration is **only suitable for lab/demo use** inside a controlled vNet.  
For production, you should move to:

- WinRM over HTTPS (port 5986)
- Encrypted traffic
- Stronger authentication (Kerberos, certificate, etc.)
- Tight inbound NSG rules


## Tying This into the Ansible Workshop

Once this Terraform lab is deployed:

1. SSH into the Ansible controller using the public IP output:
   ```bash
   ssh labadmin@<ansible_controller_public_ip>
   ```

2. Clone (or confirm) your Ansible Windows Workshop repo on the controller.

3. Edit `inventory/hosts.yml` in the Ansible repo and plug in the `windows_vm_private_ips` values as hosts.

4. Run the labs from the controller, e.g.:

   ```bash
   ansible-playbook -i inventory/hosts.yml playbooks/01_ping.yml
   ```

This way, you can re-use the same Terraform pattern to spin up a fully baked Ansible + Windows lab per user, per team, or per environment with minimal changes.
