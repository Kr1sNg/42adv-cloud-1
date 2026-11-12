# Ansible

## 1. Introduction

**Ansible** is an open-source automation tool used to configure systems, deploy applications, and automate IT infrastructure.

It allows you to manage multiple machines from a single machine using simple YAML files called **playbooks**.

Ansible is agentless: it does not normally require an agent to be installed on managed Linux machines. It commonly connects through SSH and executes modules remotely.

### Key concepts

| Term | Description |
|---|---|
| **Control node** | The machine where Ansible is installed and executed. |
| **Managed node** | A machine that Ansible manages or configures. |
| **Inventory** | A list of managed nodes and their connection information. |
| **Playbook** | A YAML file describing the automation to execute. |
| **Play** | A set of tasks targeting a group of hosts. |
| **Task** | A single automation step in a playbook. |
| **Module** | A reusable unit of code that performs an operation, such as installing a package or creating a file. |
| **Role** | A reusable way to organize playbooks, tasks, variables, templates, and handlers. |
| **Handler** | A task that runs when notified by another task, usually when something changes. |
| **Facts** | Information automatically collected about managed nodes, such as their operating system and IP addresses. |

---

## 2. Create an Ansible environment

### 2.1. Create a Python virtual environment

Using:
```bash
source ~/.ansible/.venv/bin/activate
```

On Debian / Ubuntu:

```bash
mkdir -p ~/ansible
cd ~/ansible

python3 -m venv .venv
source .venv/bin/activate

python -m pip install --upgrade pip
python -m pip install ansible-dev-tools
```

Verify the installation:

```bash
ansible --version
ansible-playbook --version
```

### 2.2. Use Ansible with VS Code

Open your Ansible project in VS Code.

Activate the virtual environment in the integrated terminal:

```bash
source ~/ansible/.venv/bin/activate
```

To leave the virtual environment:

```bash
deactivate
```

**Important:** Configure VS Code to use the same Python interpreter:

```text
~/ansible/.venv/bin/python
```

You can select it using `Python: Select Interpreter` in the VS Code Command Palette.

---

## 3. Connection types and managed nodes

Different platforms use different connection methods.

| Platform | Connection | Description |
|---|---|---|
| Linux | `ssh` | Connect through SSH. |
| Windows | `winrm` | Connect through Windows Remote Management. |
| Network devices | `network_cli` | Connect through a network CLI, commonly SSH. |
| Local machine | `local` | Execute tasks directly on the control node. |
| Cloud resources | Usually cloud-specific modules | Manage cloud resources through provider APIs. |

### Example inventory

```ini
[linux_servers]
server1 ansible_host=192.168.1.10 ansible_user=ubuntu

[windows_servers]
windows1 ansible_host=192.168.1.20 ansible_connection=winrm

[local]
localhost ansible_connection=local
```

For cloud platforms such as Azure, Ansible can use cloud-specific collections and modules to manage resources through their APIs.

### Azure SSH connection example

For an Azure Linux virtual machine:

```ini
[azure_servers]
my_vm ansible_host=20.10.10.10 ansible_user=azureuser
```

`azureuser` is an example of an SSH username. The actual username depends on the one configured when the VM was created.

---

## 4. Ansible beginner exercises

These exercises use `localhost` so you can learn Ansible without needing a remote server.

### Level 1 – Fundamentals

#### Exercise 1: Check whether your server is reachable

**Learn:** Inventory, hosts, modules, and ad-hoc commands.

Create `inventory.ini`:

```ini
[local]
localhost ansible_connection=local
```

Execute:

```bash
ansible all -i inventory.ini -m ansible.builtin.ping
```

Expected result:

```json
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

**Concept:** Ansible connects to the target host and executes a module.

Note: The Ansible ping module tests whether Ansible can communicate with the host. It does not send an ICMP ping packet.

#### Exercise 2: Get system information

**Learn:** Facts gathering.

Execute:

```bash
ansible all -i inventory.ini -m ansible.builtin.setup
```

This collects information about the managed machine.

Try filtering the information:

```bash
ansible all -i inventory.ini -m ansible.builtin.setup \
  -a 'filter=ansible_distribution*'
```

Expected: Linux distribution and version information.

**Concept:** Facts are variables automatically collected by Ansible. They can be used in playbooks to make decisions based on the target machine.

#### Exercise 3: Check disk space and memory

**Learn:** Command module.

Check disk space:

```bash
ansible all -i inventory.ini -m ansible.builtin.command \
  -a "df -h"
```

Check memory:

```bash
ansible all -i inventory.ini -m ansible.builtin.command \
  -a "free -h"
```

Compare the output with running the same commands directly in your terminal.

**Concept:** The `command` module executes a command on the target machine without using a shell.

---

### Level 2 – Basic automation with modules

#### Exercise 4: Create a directory and a file

**Learn:** `file` and `copy` modules.

Create `create_file.yml`:

```yaml
---
- name: Create my first files
  hosts: local
  tasks:
    - name: Create a directory
      ansible.builtin.file:
        path: /tmp/ansible-lab
        state: directory
        mode: '0755'

    - name: Create a text file
      ansible.builtin.copy:
        content: "Hello from Ansible!\n"
        dest: /tmp/ansible-lab/hello.txt
```

Run:

```bash
ansible-playbook -i inventory.ini create_file.yml
```

Verify:

```bash
cat /tmp/ansible-lab/hello.txt
```

**Challenge:** Run the playbook twice. Does Ansible make changes the second time?

**Concept:** Ansible modules are generally designed to be idempotent. This means that running the same playbook multiple times should not make unnecessary changes when the desired state has already been achieved.

#### Exercise 5: Install a package

**Learn:** Package management and privilege escalation.

Create `install_package.yml`:

```yaml
---
- name: Install a package
  hosts: local
  become: true
  tasks:
    - name: Install curl
      ansible.builtin.apt:
        name: curl
        state: present
        update_cache: true
```

Run:

```bash
ansible-playbook -i inventory.ini install_package.yml -K
```

Verify:

```bash
curl --version
```

**Challenge:** Change `curl` to `git` and install it.

**Concept:** `become: true` enables privilege escalation, usually through `sudo`, so Ansible can perform administrative operations.

---

### Level 3 – Delete resources and manage packages

#### Exercise 6: Delete a directory and all its files

**Learn:** File deletion with the `file` module.

Create `delete_file.yml`:

```yaml
---
- name: Delete my Ansible lab
  hosts: local
  tasks:
    - name: Delete the directory and all its contents
      ansible.builtin.file:
        path: /tmp/ansible-lab
        state: absent
```

Run:

```bash
ansible-playbook -i inventory.ini delete_file.yml
```

Verify:

```bash
ls -la /tmp/ansible-lab
```

The directory and everything inside it will be deleted recursively.

**Important:** `state: absent` works for both files and directories.

For example, to delete only one file:

```yaml
- name: Delete hello.txt
  ansible.builtin.file:
    path: /tmp/ansible-lab/hello.txt
    state: absent
```

#### Exercise 7: Uninstall a package

**Learn:** Package removal with the `apt` module.

Create `remove_package.yml`:

```yaml
---
- name: Remove a package
  hosts: local
  become: true
  tasks:
    - name: Uninstall curl
      ansible.builtin.apt:
        name: curl
        state: absent
```

Run:

```bash
ansible-playbook -i inventory.ini remove_package.yml -K
```

Verify:

```bash
dpkg -s curl
```

If the package has been removed, `dpkg` will report that the package is not installed.

**Concept:**

- `state: absent`: Uninstalls the package but normally keeps its configuration files.
- `state: purge`: Uninstalls the package and removes its configuration files where supported.

---

## 5. Important Ansible command-line options

| Option | Meaning |
|---|---|
| `-i` | Specify the inventory file. |
| `-m` | Specify the module for an ad-hoc command. |
| `-a` | Pass arguments to a module. |
| `-u` | Specify the remote SSH/Linux username. |
| `-b` | Enable privilege escalation (`become`). |
| `-K` | Ask for the privilege escalation password. |
| `--ask-pass` | Ask for the SSH connection password. |
| `-v` | Display more execution details. |
| `--check` | Perform a dry run where supported. |
| `--diff` | Show file changes where supported. |

### Important distinction: `--ask-pass` vs `-K`

- `--ask-pass`: Password used to connect to a remote machine through SSH.
- `-K` (`--ask-become-pass`): Password used to obtain elevated privileges through `sudo`.

For the local package installation exercise, use:

```bash
ansible-playbook -i inventory.ini install_package.yml -K
```

---

## 6. Understanding Ansible module states

The `state` parameter describes the desired state of a resource.

| Module | State | Meaning |
|---|---|---|
| `file` | `directory` | Ensure a directory exists. |
| `file` | `touch` | Ensure a file exists, creating it if necessary. |
| `file` | `absent` | Delete a file or directory. |
| `apt` | `present` | Ensure a package is installed. |
| `apt` | `absent` | Uninstall a package. |
| `apt` | `latest` | Ensure the latest package version is installed. |
| `apt` | `purge` | Uninstall a package and purge its configuration. |

**Remember:** Ansible describes the desired state of your infrastructure, rather than simply listing commands to execute.

---

## 7. Ansible Vault – Manage sensitive information

**Ansible Vault** allows you to encrypt sensitive information such as passwords, API tokens, SSH credentials, and database credentials.

It protects sensitive variables while allowing you to store encrypted files in a Git repository.

### 7.1. Useful Ansible Vault commands

| Command | Purpose |
|---|---|
| `ansible-vault create secrets.yml` | Create a new encrypted file. |
| `ansible-vault edit secrets.yml` | Edit an encrypted file. |
| `ansible-vault view secrets.yml` | View decrypted content without modifying the file. |
| `ansible-vault encrypt secrets.yml` | Encrypt an existing file. |
| `ansible-vault decrypt secrets.yml` | Decrypt an encrypted file. |
| `ansible-vault rekey secrets.yml` | Change the Vault password. |

### 7.2. Create an encrypted secrets file

Create a new encrypted file:

```bash
ansible-vault create secrets.yml
```

Ansible will ask you to create a Vault password.

Example content:

```yaml
---
db_username: admin
db_password: my_secure_password
domain_name: login.42.fr
```

The file is encrypted when you save and exit the editor.

### 7.3. Use Vault variables in a playbook

Example project structure:

```text
ansible/
├── inventory.ini
├── secrets.yml
└── configure_server.yml
```

In `configure_server.yml`:

```yaml
---
- name: Configure server
  hosts: local
  vars_files:
    - secrets.yml

  tasks:
    - name: Display database username
      ansible.builtin.debug:
        msg: "Database username: {{ db_username }}"
```

Run the playbook:

```bash
ansible-playbook -i inventory.ini configure_server.yml --ask-vault-pass
```

Ansible asks for the Vault password to decrypt `secrets.yml` before executing the playbook.

### 7.4. Use a Vault password file

Instead of entering the password every time, you can use a password file:

```bash
ansible-playbook -i inventory.ini configure_server.yml \
  --vault-password-file ~/.ansible/vault_pass
```

**Security warning:**
- Never commit the Vault password file to Git.
- Restrict its permissions:

```bash
chmod 600 ~/.ansible/vault_pass
```

- For CI/CD pipelines, store the Vault password in a protected secret store rather than in your repository.

### 7.5. Important security practices

- Encrypt sensitive variables with Ansible Vault.
- Never commit plaintext secrets to Git.
- Add generated `.env` files and Vault password files to `.gitignore`.
- Use `no_log: true` on tasks that might expose sensitive values.
- Keep separate secrets for development, testing, and production environments.

**Important distinction:**

| Component | Purpose |
|---|---|
| Ansible Vault | Encrypt sensitive information at rest. |
| `secrets.yml` | Stores encrypted variables. |
| `.env.j2` | Template used by Ansible to generate an environment file. |
| `.env` | Generated file containing the actual application environment variables. |
| Docker Compose | Uses environment variables to configure containers. |

A common deployment workflow is:

```text
Encrypted secrets.yml
        |
        v
   Ansible Vault
        |
        v
  Ansible Playbook
        |
        v
 Render .env.j2 template
        |
        v
  Generate .env (mode 0600)
        |
        v
   Docker Compose
        |
        v
    Containers
```

This allows you to keep encrypted secrets in Git while generating the actual `.env` file securely on the target server.

---

## 8. Useful references

- [Official Ansible documentation](https://docs.ansible.com/)
- [Ansible getting started](https://docs.ansible.com/ansible/latest/getting_started/index.html)
- [Ansible module index](https://docs.ansible.com/ansible/latest/collections/index_module.html)
- [Ansible Vault documentation](https://docs.ansible.com/ansible/latest/vault_guide/index.html)
- [Ansible community collections](https://galaxy.ansible.com/)
