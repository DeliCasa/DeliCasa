#!/bin/bash

# Setup Pi Orchestrator SSH Connection
# This script sets up secure SSH connection to the Raspberry Pi

set -e

# Default values
PI_HOST="${PI_HOST:-192.168.1.100}"
PI_USERNAME="${PI_USERNAME:-pi}"
PI_SSH_PORT="${PI_SSH_PORT:-22}"
SSH_KEY_PATH="$HOME/.ssh/id_rsa_delicasa_pi"

echo "🔧 DeliCasa Pi Orchestrator Connection Setup"
echo "============================================="

# Function to check if SSH key exists
check_ssh_key() {
    if [ ! -f "$SSH_KEY_PATH" ]; then
        echo "📝 Creating SSH key for Pi connection..."
        ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "delicasa-development"
        echo "✅ SSH key created at $SSH_KEY_PATH"
    else
        echo "🔑 SSH key already exists at $SSH_KEY_PATH"
    fi
}

# Function to copy SSH key to Pi
setup_ssh_access() {
    echo "📤 Setting up SSH access to Pi at $PI_HOST..."
    
    if ! ssh-copy-id -i "${SSH_KEY_PATH}.pub" -p "$PI_SSH_PORT" "$PI_USERNAME@$PI_HOST" 2>/dev/null; then
        echo "❌ Failed to copy SSH key automatically."
        echo "Please manually copy your SSH key to the Pi:"
        echo "   ssh-copy-id -i ${SSH_KEY_PATH}.pub -p $PI_SSH_PORT $PI_USERNAME@$PI_HOST"
        echo "Or manually add this key to ~/.ssh/authorized_keys on the Pi:"
        cat "${SSH_KEY_PATH}.pub"
        return 1
    fi
    
    echo "✅ SSH key copied successfully"
}

# Function to test SSH connection
test_connection() {
    echo "🧪 Testing SSH connection to Pi..."
    
    if ssh -i "$SSH_KEY_PATH" -p "$PI_SSH_PORT" -o ConnectTimeout=10 -o BatchMode=yes "$PI_USERNAME@$PI_HOST" "echo 'SSH connection successful'" 2>/dev/null; then
        echo "✅ SSH connection test successful"
        return 0
    else
        echo "❌ SSH connection test failed"
        return 1
    fi
}

# Function to check if Pi Orchestrator is running
check_pi_service() {
    echo "🔍 Checking if Pi Orchestrator is running..."
    
    if ssh -i "$SSH_KEY_PATH" -p "$PI_SSH_PORT" "$PI_USERNAME@$PI_HOST" "pgrep -f 'pi.*orchestrator' > /dev/null" 2>/dev/null; then
        echo "✅ Pi Orchestrator is running"
        return 0
    else
        echo "⚠️  Pi Orchestrator is not running or not found"
        echo "You may need to start it manually on the Pi:"
        echo "   ssh -i $SSH_KEY_PATH -p $PI_SSH_PORT $PI_USERNAME@$PI_HOST"
        echo "   cd /path/to/PiOrchestrator && make run-hex-dev"
        return 1
    fi
}

# Function to setup SSH config
setup_ssh_config() {
    local ssh_config="$HOME/.ssh/config"
    local config_entry="
# DeliCasa Pi Orchestrator
Host delicasa-pi
    HostName $PI_HOST
    User $PI_USERNAME
    Port $PI_SSH_PORT
    IdentityFile $SSH_KEY_PATH
    IdentitiesOnly yes
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
"

    # Check if entry already exists
    if grep -q "Host delicasa-pi" "$ssh_config" 2>/dev/null; then
        echo "🔧 SSH config entry already exists"
    else
        echo "📝 Adding SSH config entry..."
        echo "$config_entry" >> "$ssh_config"
        chmod 600 "$ssh_config"
        echo "✅ SSH config entry added"
    fi
}

# Main execution
main() {
    echo "Configuration:"
    echo "  Pi Host: $PI_HOST"
    echo "  Username: $PI_USERNAME"
    echo "  SSH Port: $PI_SSH_PORT"
    echo "  SSH Key: $SSH_KEY_PATH"
    echo ""
    
    # Step 1: Check/create SSH key
    check_ssh_key
    
    # Step 2: Setup SSH config
    setup_ssh_config
    
    # Step 3: Setup SSH access
    if ! setup_ssh_access; then
        echo "⚠️  SSH setup incomplete. Please follow manual instructions above."
        exit 1
    fi
    
    # Step 4: Test connection
    if ! test_connection; then
        echo "❌ Connection test failed. Please check your Pi configuration."
        exit 1
    fi
    
    # Step 5: Check Pi service
    check_pi_service
    
    echo ""
    echo "🎉 Pi Orchestrator connection setup complete!"
    echo ""
    echo "You can now:"
    echo "  • Connect to Pi: ssh delicasa-pi"
    echo "  • Start services: docker-compose up"
    echo "  • Check Pi status: ssh delicasa-pi 'systemctl status pi-orchestrator'"
    echo ""
    echo "The Pi Orchestrator will be accessible at: http://$PI_HOST:9000"
}

# Handle command line arguments
case "${1:-}" in
    "test")
        test_connection
        check_pi_service
        ;;
    "setup")
        main
        ;;
    *)
        main
        ;;
esac