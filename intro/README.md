# Ansible

## Create environment for Ansible

mkdir -p ~/ansible
cd ~/ansible

python3 -m venv .venv
source .venv/bin/activate

python -m pip install --upgrade pip
python -m pip install ansible-dev-tools

Then using in VS code:

```bash
source ~/.ansible/.venv/bin/activate

deactivate
```

## Vocab

- `control node`: the machine running Ansible (it's us)

- `managed nodes`: targeted machines which are going to be configured by Ansible

- All different types of platforms have different means of being connected

```yaml
# Windows
hosts: all_windows_machines
connection: winrm

# Linux
hosts: all_linux_machines
connection: ssh

# network devices
hosts: all_network_devices
connection: network_cli

# cloud
hosts: all_cloud_environments
connection: local
```
 
- `name`: 


## Azure

azureuser

## Ansible beginner exercises
Level 1 – Fundamentals
Beginner

1. Check whether your server is reachable

Learn: Inventory, hosts, modules, ad-hoc commands.

Create inventory.ini:
[local]
localhost ansible_connection=local


Execute:
ansible all -i inventory.ini -m ping


Expected result: SUCCESS and "ping": "pong".

Concept: Ansible connects to hosts and executes modules.

2. Get system information

Learn: Facts gathering.
ansible all -i inventory.ini -m setup


Try filtering information:
ansible all -i inventory.ini -m setup \
  -a 'filter=ansible_distribution*'


Expected: Linux distribution and version information.

3. Check disk space and memory

Learn: Command and shell modules.
ansible all -i inventory.ini -m command \
  -a "df -h"


Then:
ansible all -i inventory.ini -m command \
  -a "free -h"


Compare the output with running commands directly in your terminal.

Level 2 – Basic automation with modules
Beginner
4. Create a directory and a file

Learn: file and copy modules.

Create create_file.yml:
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


Run:
ansible-playbook -i inventory.ini create_file.yml


Verify:
cat /tmp/ansible-lab/hello.txt


Challenge: Run the playbook twice. Does Ansible make changes the second time?

5. Install a package

Learn: Package management and privilege escalation.

Create install_package.yml:
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


Run:
ansible-playbook -i inventory.ini install_package.yml --ask-become-pass


Verify:
curl --version


Challenge: Change curl to git and install it.

3. Understand these Ansible options
Option	Meaning
-u username	SSH/Linux user to connect as
-b	Enable privilege escalation (become)
-K	Ask for become password
--ask-pass	Ask for SSH connection password

Important distinction:
- --ask-pass = password to connect to a remote machine.
- --ask-become-pass = password to obtain elevated privileges using sudo.
For your current exercise, use:
ansible-playbook -i inventory.ini install_package.yml -K

1. Delete a directory and all its files
Create delete_file.yml:

---
- name: Delete my Ansible lab
  hosts: local
  tasks:
    - name: Delete the directory and all its contents
      ansible.builtin.file:
        path: /tmp/ansible-lab
        state: absent



Run:
ansible-playbook -i inventory.ini delete_file.yml


Verify:
ls -la /tmp/ansible-lab


The directory and everything inside it will be deleted recursively.

Important: state: absent works for both files and directories.

For example, to delete only one file:
- name: Delete hello.txt
  ansible.builtin.file:
    path: /tmp/ansible-lab/hello.txt
    state: absent


2. Uninstall a package
Create remove_package.yml:

---
- name: Remove a package
  hosts: local
  become: true
  tasks:
    - name: Uninstall curl
      ansible.builtin.apt:
        name: curl
        state: absent



Run:
ansible-playbook -i inventory.ini remove_package.yml --ask-become-pass


Verify:
dpkg -l curl


state: absent uninstalls the package but keeps its configuration files where applicable.

If you also want to remove package configuration files, use:
state: purge


3. Understand the different states
Module	State	Meaning
file	present	Ensure file exists
file	directory	Ensure directory exists
file	absent	Delete file/directory
apt	present	Ensure package is installed
apt	absent	Uninstall package
apt	latest	Install/update to latest version
apt	purge	Uninstall and purge configuration