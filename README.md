# Run

```shell
ansible-playbook playbook.yml
```

# Generating SSH Key

To generate an SSH key pair for use with your Ansible setup, follow these steps:

1. **Open Your Terminal or Command Prompt**:

    - **Linux/macOS**: Use the Terminal application.
    - **Windows**: Use PowerShell or Command Prompt.

2. **Generate the SSH Key Pair**:

   Run the following command, replacing `/path/to/ssh_key` with the desired file path for your SSH key:

   ```bash
   ssh-keygen -t rsa -b 4096 -f /path/to/ssh_key -C "your_email@example.com"
   ```

    - **`-t rsa`**: Specifies the RSA algorithm.
    - **`-b 4096`**: Sets the key length to 4096 bits for security.
    - **`-f /path/to/ssh_key`**: Defines the file path and name for the key.
    - **`-C "your_email@example.com"`**: Adds a comment (optional).

   **Example**:

   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible_key -C "ansible_deployment"
   ```

   Press **Enter** when prompted for a passphrase (leave it empty for automation purposes).

3. **Set the `SSH_KEY_PATH` Environment Variable**:

    - **Linux/macOS**:

      ```bash
      export SSH_KEY_PATH="~/.ssh/ansible_key"
      ```

    - **Windows PowerShell**:

      ```powershell
      $env:SSH_KEY_PATH = "C:\Users\YourUsername\.ssh\ansible_key"
      ```

4. **Ensure Ansible Can Access the Key**:

   Make sure the private key file is readable by Ansible and that the public key (`ansible_key.pub`) is present in the same directory.

5. **Initial Password-Based Connection**:

   Since password authentication is initially required to set up SSH keys on the remote hosts, ensure that `ansible_ssh_pass` is correctly set in your `host_vars` for each host.

6. **Run the Ansible Playbook**:

   Execute your playbook to apply the configurations:

   ```bash
   ansible-playbook playbook.yml
   ```

   The playbook will:

    - Use the provided passwords to connect to each host.
    - Copy your public SSH key to the remote servers.
    - Disable password authentication, enforcing key-based authentication for future connections.

7. **Verify SSH Key Authentication (Optional)**:

   After the playbook runs, test the SSH connection:

   ```bash
   ssh -i ~/.ssh/ansible_key root@your_server_ip
   ```

   You should be able to log in without being prompted for a password.

**Note**: Keep your private key (`ansible_key`) secure and never share it. Only distribute the public key (`ansible_key.pub`) to the servers.

# WireGuard

Understood! You want to generate WireGuard keys locally on your machine and then use them when provisioning all hosts with Ansible. This approach allows you to have full control over the keys and ensures consistent configuration across all your hosts.

Below are the detailed steps to generate the WireGuard keys locally, securely include them in your Ansible setup, and update your playbooks and templates accordingly.

---

### **1. Generate WireGuard Key Pairs for Each Host Locally**

You'll need to generate a unique WireGuard private and public key pair for each host: `vps1`, `vps2`, and `rancher`.

**Prerequisites:**

- Ensure that WireGuard tools are installed on your local machine.

   - **Linux/macOS:**

     ```bash
     sudo apt install wireguard-tools        # Debian/Ubuntu
     sudo yum install wireguard-tools        # CentOS/RHEL
     brew install wireguard-tools            # macOS with Homebrew
     ```

- **Windows:**

   - Use WSL (Windows Subsystem for Linux) or install WireGuard for Windows and use the command line tools.

**Generate Keys:**

Open your terminal and run the following commands for each host.

#### **For `vps1`:**

```bash
wg genkey | tee vps1_privatekey | wg pubkey > vps1_publickey
```

#### **For `vps2`:**

```bash
wg genkey | tee vps2_privatekey | wg pubkey > vps2_publickey
```

#### **For `rancher`:**

```bash
wg genkey | tee rancher_privatekey | wg pubkey > rancher_publickey
```

You should now have six files:

- `vps1_privatekey` and `vps1_publickey`
- `vps2_privatekey` and `vps2_publickey`
- `rancher_privatekey` and `rancher_publickey`

---

### **2. Securely Store the Keys Using Ansible Vault**

Since private keys are sensitive, you should store them securely. Ansible Vault allows you to encrypt variable files containing sensitive data.

**Create `host_vars` Files for Each Host:**

#### **`host_vars/vps1.yml`:**

```yaml
ansible_password: "{{ lookup('env', 'VPS1_PASSWORD') }}"
wireguard_private_key: "{{ lookup('file', 'keys/vps1_privatekey') }}"
wireguard_public_key: "{{ lookup('file', 'keys/vps1_publickey') }}"
```

#### **`host_vars/vps2.yml`:**

```yaml
ansible_password: "{{ lookup('env', 'VPS2_PASSWORD') }}"
wireguard_private_key: "{{ lookup('file', 'keys/vps2_privatekey') }}"
wireguard_public_key: "{{ lookup('file', 'keys/vps2_publickey') }}"
```

#### **`host_vars/rancher.yml`:**

```yaml
ansible_password: "{{ lookup('env', 'RANCHER_PASSWORD') }}"
wireguard_private_key: "{{ lookup('file', 'keys/rancher_privatekey') }}"
wireguard_public_key: "{{ lookup('file', 'keys/rancher_publickey') }}"
```

**Note:**

- Place the key files (`vps1_privatekey`, etc.) in a directory called `keys/` within your Ansible project directory.
- Update the `lookup('file', ...)` paths if you store the keys elsewhere.

**Encrypt the `host_vars` Files:**

To protect the private keys, encrypt the `host_vars` files using Ansible Vault.

```bash
ansible-vault encrypt host_vars/vps1.yml
ansible-vault encrypt host_vars/vps2.yml
ansible-vault encrypt host_vars/rancher.yml
```

**Set Up Vault Password File (Optional):**

You can create a vault password file for convenience.

```bash
echo 'your_vault_password' > vault_pass.txt
chmod 600 vault_pass.txt
```

---

### **3. Update Ansible Configuration and Playbooks**

**Update `ansible.cfg`:**

Add the vault password file path if you created one.

```ini
[defaults]
inventory = inventory
host_key_checking = False
retry_files_enabled = False
vault_password_file = vault_pass.txt
```

**Ensure Environment Variables Are Set:**

Set the passwords for each host.

```bash
export VPS1_PASSWORD='your_vps1_password'
export VPS2_PASSWORD='your_vps2_password'
export RANCHER_PASSWORD='your_rancher_password'
```

---

### **4. Update the WireGuard Role and Templates**

**Modify `roles/wireguard/tasks/main.yml`:**

Ensure that the tasks use the private and public keys provided.

```yaml
- name: Ensure /etc/wireguard directory exists
  file:
    path: /etc/wireguard
    state: directory
    mode: 0700

- name: Copy WireGuard private key
  copy:
    dest: /etc/wireguard/privatekey
    content: "{{ wireguard_private_key }}"
    mode: 0600

- name: Copy WireGuard public key
  copy:
    dest: /etc/wireguard/publickey
    content: "{{ wireguard_public_key }}"
    mode: 0644
```

**Update `roles/wireguard/templates/wg0.conf.j2`:**

Ensure the template uses the keys and public keys for peer configuration.

```ini
[Interface]
Address = {{ vpn_address_map[inventory_hostname] }}
PrivateKey = {{ wireguard_private_key }}
ListenPort = {{ wireguard_port }}

{% for host in groups['all'] %}
{% if host != inventory_hostname %}
[Peer]
PublicKey = {{ hostvars[host]['wireguard_public_key'] }}
Endpoint = {{ hostvars[host]['ansible_host'] }}:{{ wireguard_port }}
AllowedIPs = {{ vpn_address_map[host] }}
PersistentKeepalive = 25
{% endif %}
{% endfor %}
```

---

### **5. Ensure Host Variables Are Loaded Correctly**

Ansible will automatically load the variables from the `host_vars` directory as long as the directory is correctly placed and the filenames match the hostnames in your inventory.

**Directory Structure:**

```
ansible.cfg
inventory
playbook.yml
host_vars/
  ├── vps1.yml
  ├── vps2.yml
  └── rancher.yml
group_vars/
roles/
keys/
  ├── vps1_privatekey
  ├── vps1_publickey
  ├── vps2_privatekey
  ├── vps2_publickey
  ├── rancher_privatekey
  └── rancher_publickey
```

---

### **6. Run the Ansible Playbook**

Run your playbook to configure the hosts.

```bash
ansible-playbook playbook.yml
```

- If you didn't set `vault_password_file` in `ansible.cfg`, provide the vault password when prompted or use the `--vault-password-file` option.

  ```bash
  ansible-playbook playbook.yml --vault-password-file=vault_pass.txt
  ```

---

### **7. Verify the WireGuard Configuration**

After the playbook completes, SSH into each host and verify the WireGuard configuration.

**On `vps1`:**

```bash
ssh root@VPS1_IP

# Check WireGuard status
wg show
```

**Check `/etc/wireguard/wg0.conf`:**

Ensure that the configuration file contains the correct private key and peer information.

---

### **8. Summary of Steps**

- **Generate WireGuard Keys Locally:**

   - Use `wg genkey` and `wg pubkey` to generate keys for each host.

- **Securely Store the Keys:**

   - Place the keys in the `keys/` directory.
   - Use Ansible Vault to encrypt `host_vars` files containing private keys.

- **Update Ansible Configuration:**

   - Modify `ansible.cfg`, playbooks, and roles to use the generated keys.

- **Run the Playbook:**

   - Execute the playbook to configure WireGuard on all hosts.

- **Verify Configuration:**

   - SSH into each host and check the WireGuard setup.

---

### **Additional Considerations**

#### **Use Ansible Vault for Keys Only**

- Instead of storing the actual key contents in the `host_vars` files, you can read them from the local files.

- Modify `host_vars/vps1.yml`:

  ```yaml
  ansible_password: "{{ lookup('env', 'VPS1_PASSWORD') }}"
  wireguard_private_key: "{{ lookup('file', 'keys/vps1_privatekey') }}"
  wireguard_public_key: "{{ lookup('file', 'keys/vps1_publickey') }}"
  ```

- Since the keys are stored in files, ensure these files are not committed to version control.

#### **Exclude Keys from Version Control**

- Add the `keys/` directory to your `.gitignore` file to prevent committing sensitive keys.

  **Create `.gitignore`:**

  ```
  keys/
  vault_pass.txt
  ```

#### **Securely Handle Vault Password**

- Do not store `vault_pass.txt` in version control.

- Consider prompting for the vault password at runtime instead of using a password file.

#### **Automation of Key Generation**

- For a large number of hosts, you can automate the key generation process using a script.

**Example Script `generate_keys.sh`:**

```bash
#!/bin/bash

hosts=("vps1" "vps2" "rancher")

mkdir -p keys

for host in "${hosts[@]}"; do
  wg genkey | tee keys/${host}_privatekey | wg pubkey > keys/${host}_publickey
done
```

- Run the script:

  ```bash
  bash generate_keys.sh
  ```

---

### **Using Ansible to Generate Keys (Alternative)**

If you prefer not to generate keys manually, you can have Ansible generate them during the playbook execution.

**Modify `roles/wireguard/tasks/main.yml`:**

```yaml
- name: Generate WireGuard private key
  command: wg genkey
  register: wg_private_key
  changed_when: wg_private_key.stdout != ''
  args:
    creates: /etc/wireguard/privatekey

- name: Save private key
  copy:
    dest: /etc/wireguard/privatekey
    content: "{{ wg_private_key.stdout }}"
    mode: 0600

- name: Generate WireGuard public key
  command: echo "{{ wg_private_key.stdout }}" | wg pubkey
  register: wg_public_key

- name: Save public key
  copy:
    dest: /etc/wireguard/publickey
    content: "{{ wg_public_key.stdout }}"
    mode: 0644

- name: Set WireGuard public key as host fact
  set_fact:
    wireguard_public_key: "{{ wg_public_key.stdout }}"
```

**Adjust the Template:**

Use `hostvars` to access the public keys.

```ini
[Interface]
Address = {{ vpn_address_map[inventory_hostname] }}
PrivateKey = {{ wg_private_key.stdout }}
ListenPort = {{ wireguard_port }}

{% for host in groups['all'] %}
{% if host != inventory_hostname %}
[Peer]
PublicKey = {{ hostvars[host]['wireguard_public_key'] }}
Endpoint = {{ hostvars[host]['ansible_host'] }}:{{ wireguard_port }}
AllowedIPs = {{ vpn_address_map[host] }}
PersistentKeepalive = 25
{% endif %}
{% endfor %}
```

**Note:**

- This method requires that Ansible runs the playbook against all hosts simultaneously to share facts.
- It may not be suitable if hosts are added incrementally.

---

### **Conclusion**

By generating the WireGuard keys locally and securely incorporating them into your Ansible setup, you maintain control over the keys and ensure consistent configuration across all your hosts. Using Ansible Vault protects sensitive information, and updating your playbooks and templates ensures the keys are correctly deployed.

---

### **Next Steps**

- **Test the Setup:**

   - Run the playbook in a controlled environment to verify that everything works as expected.

- **Monitor the Hosts:**

   - After deployment, monitor the hosts to ensure they are communicating over the WireGuard VPN.

- **Documentation:**

   - Document the process and update any internal guides for future reference.

---

**Feel free to ask if you have any questions or need further assistance with any of the steps!**