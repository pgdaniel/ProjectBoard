#!/bin/bash
set -e

echo "=== Project Board Ansible Deployment ==="

# Check required environment variables
REQUIRED_VARS=("DOCKER_PASSWORD" "RAILS_MASTER_KEY" "DATABASE_URL")

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var environment variable not set"
        echo ""
        echo "Required environment variables:"
        echo "  DOCKER_PASSWORD     - Docker Hub password/token"
        echo "  RAILS_MASTER_KEY    - Rails master key (from config/master.key)"
        echo "  DATABASE_URL        - PostgreSQL connection string"
        echo "                        (e.g., postgresql://user:pass@host:25060/db?sslmode=require)"
        echo ""
        echo "Usage:"
        echo "  DOCKER_PASSWORD=xxx RAILS_MASTER_KEY=xxx DATABASE_URL='postgresql://...' ./bin/deploy-ansible.sh"
        exit 1
    fi
done

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "Error: ansible-playbook not found. Please install Ansible:"
    echo "  pip install ansible"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"

echo "Project root: $PROJECT_ROOT"
echo "Ansible directory: $ANSIBLE_DIR"

# Run the playbook
echo ""
echo "Running Ansible deployment..."
ansible-playbook \
    -i "$ANSIBLE_DIR/inventory.ini" \
    "$ANSIBLE_DIR/deploy.yml" \
    -e "docker_registry_password=$DOCKER_PASSWORD" \
    -v

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Your application should now be running:"
echo "  Rails API: https://dashcmd.com/api/v1"
echo "  React App: https://app.dashcmd.com"
echo ""
echo "Make sure your DNS records are set up:"
echo "  dashcmd.com A 159.65.251.69"
echo "  app.dashcmd.com A 159.65.251.69"
