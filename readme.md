# ansible-infrastructure
Consolidated Repository of Ansible Roles

## Install Ansible

On **Macintosh**, we can install Ansible doing the following:

```bash
# Using Brew (recommended)
# This assumes you have Homebrew installed already
brew update
brew install ansible

# Using Python only
sudo easy_install pip
sudo pip install -U pip
sudo pip install ansible
```

On **RedHat/CentOS**, we can do the following after adding the EPEL repository:

```bash
# Install using package manager
sudo yum install epel-release
sudo yum install ansible

# Or install pip via package manager
sudo yum install epel-release
sudo yum install python-pip
sudo pip install -U pip
sudo pip install Ansible

# Or via Python only, if
# easy_install is on the server
sudo easy_install pip
sudo pip install -U pip
sudo pip install ansible
```

On **Debian/Ubuntu** you can install via pip:

```bash
# Via package manager
sudo apt-get install -y python-pip
sudo pip install -U pip
sudo pip install ansible

# Or via Python only
sudo easy_install pip
sudo pip install -U pip
sudo pip install ansible
```

On **Ubuntu** (*not* Debian), you can also install it via a PPA repository:

```bash
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
```

### Security

As the variables in the Group Vars are sensitive, you should consider not adding these to a repository on the internet. However, if you do, definitely make use of Ansible Vault to encrypt them.

You'll need a password to use to encrypt/decrypt variables within these files.

Here's how to do that:

```bash
# Encrypt "all" variable file, and create a password
ansible-vault encrypt group_vars/all
> CREATE PASSWORD AS PROMPTED

# Encrypt "build_server" variable file, and create a password
# Use the same password as used above
ansible-vault encrypt group_vars/build_server
> CREATE PASSWORD AS PROMPTED

# Encrypt any other file with sensitive variables
# Use the same password as used above
# In this case, we encrypt the "web" variable file
#   which contains a GitHub access token
ansible-vault encrypt group_vars/web
> CREATE PASSWORD AS PROMPTED
```

Once encrypted, you can edit these files using `ansible-vault` as well:

```bash
ansible-vault edit group_vars/all
> ENTER PASSWORD AS PROMPTED
```

This will open the files in the editor of your choice, as defined by the `$EDITOR` environment variable (usually nano or vim).

This file will be changed if you open the file but make no changes, as the file is re-encrypted every time it is opened (and then closed) using the `ansible-vault` tool. Directly editing the file will show an encrypted hash of the file.

## Run Ansible

Once these are all set (or to test if we messed something up) we can finally run Ansible and get started!

```bash
cd ~/path/to/deploy-dist

# Check our Yaml Syntax
ANSIBLE_SSH_ARGS='-o IdentitiesOnly=yes -o ControlMaster=auto -o ControlPersist=60s' \
ansible-playbook --private-key=~/.ssh/id_rsa \
-i ./hosts \
--syntax-check \
--ask-vault-pass \
play.yml

# Run Everything!
ANSIBLE_SSH_ARGS='-o IdentitiesOnly=yes -o ControlMaster=auto -o ControlPersist=60s' \
ansible-playbook --private-key=~/.ssh/id_rsa \
-i ./hosts \
--ask-vault-pass \
play.yml

# Or, Limit runs by host
# In this example, we run only load_balancer tasks
ANSIBLE_SSH_ARGS='-o IdentitiesOnly=yes -o ControlMaster=auto -o ControlPersist=60s' \
ansible-playbook --private-key=~/.ssh/id_rsa \
-i ./hosts --limit=load_balancer \
--ask-vault-pass \
play.yml

# Or, Limit runs by tags
# In this example, we run only the configuration tag
ANSIBLE_SSH_ARGS='-o IdentitiesOnly=yes -o ControlMaster=auto -o ControlPersist=60s' \
ansible-playbook --private-key=~/.ssh/id_rsa \
-i ./hosts --tags="configuration" \
--ask-vault-pass \
play.yml
```

Finally we can run Ansible. The previous commands do the following:

First we set `ANSIBLE_SSH_ARGS`. The important argument here is `IdentitiesOnly yes`, which help to ensure we use only the SSH key we have available to access our servers. In my case of using AWS, this is the private key they have you download to access any and all servers you create. You might access this via user root and a password for Linode/Digital Ocean server that doesn't have a key added when you generate a server.

Then we run the Ansible command with the following flags:

* **--private-key=~/.ssh/fideloperllc.pem** - Define the private key used to access these servers. If you don't have a key pre-loaded onto the servers via your provider, see the documentation directly following this
* **-i ./hosts** - Use the `hosts` file we generated
* **--syntax-check** - Optionally, don't run the commands but instead just check the Yaml syntax
* **--ask-vault-pass** - Ask the Vault password used to encrypt the Group variables.

If you do not have an SSH key available on the server, you're likely given credentials to access the server via the `root` user, using a password. You can run Ansible that way by:

1. Adjusting the hosts file to set the SSH user
2. Telling `ansible-playbook` to ask for a user password

In the Hosts file, tell Ansible to log into each server using user `root`:

```ini
[load_balancer]
142.54.87.123  ansible_ssh_user=root

[web]
142.54.87.124  ansible_ssh_user=root
142.54.87.125  ansible_ssh_user=root

[build_server]
142.54.87.126  ansible_ssh_user=root
```

The following command tells Ansible to prompt you for the user's password. This will be the password for user `root`:

```bash
ansible-playbook \
    -i ./hosts \
    --ask-pass \
    --ask-vault-pass \
    provision.yml
```

## Example

### Host
```
tylerodonnell.com.web ansible_ssh_port=1234 ansible_ssh_host=1.2.3.4
```
