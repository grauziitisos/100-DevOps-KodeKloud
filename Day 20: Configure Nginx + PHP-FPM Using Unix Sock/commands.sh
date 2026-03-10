sudo dnf install ansible -y
nano inventory.ini
nano playbook.yaml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yaml
