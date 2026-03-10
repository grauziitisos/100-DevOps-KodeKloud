sudo dnf install ansible epel-release -y
nano inventory.ini
nano playbook.yaml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yaml
