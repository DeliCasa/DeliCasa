#!/bin/bash

# Pi Orchestrator Management Script
# This script provides easy management of the Pi Orchestrator service

set -e

PI_HOST="${PI_HOST:-192.168.1.100}"
PI_USERNAME="${PI_USERNAME:-pi}"
PI_SSH_PORT="${PI_SSH_PORT:-22}"
SSH_KEY_PATH="$HOME/.ssh/id_rsa_delicasa_pi"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to execute command on Pi
execute_on_pi() {
    local cmd="$1"
    ssh -i "$SSH_KEY_PATH" -p "$PI_SSH_PORT" -o ConnectTimeout=10 "$PI_USERNAME@$PI_HOST" "$cmd"
}

# Function to check Pi connection
check_connection() {
    log_info "Checking connection to Pi at $PI_HOST..."
    
    if execute_on_pi "echo 'Connected'" >/dev/null 2>&1; then
        log_success "Connected to Pi successfully"
        return 0
    else
        log_error "Failed to connect to Pi"
        return 1
    fi
}

# Function to get Pi status
get_status() {
    if ! check_connection; then
        return 1
    fi
    
    log_info "Getting Pi Orchestrator status..."
    
    # Check if service is running
    if execute_on_pi "pgrep -f 'orchestrator' > /dev/null" 2>/dev/null; then
        log_success "Pi Orchestrator is running"
        
        # Get process details
        local pid=$(execute_on_pi "pgrep -f 'orchestrator'")
        local uptime=$(execute_on_pi "ps -o etime= -p $pid" 2>/dev/null | tr -d ' ' || echo "unknown")
        local memory=$(execute_on_pi "ps -o rss= -p $pid" 2>/dev/null | tr -d ' ' || echo "unknown")
        
        echo "  PID: $pid"
        echo "  Uptime: $uptime"
        echo "  Memory: ${memory}KB"
        
        # Check if port is listening
        if execute_on_pi "netstat -ln | grep ':9000 ' > /dev/null" 2>/dev/null; then
            log_success "Service is listening on port 9000"
        else
            log_warning "Service is running but not listening on port 9000"
        fi
    else
        log_warning "Pi Orchestrator is not running"
    fi
    
    # System info
    local load=$(execute_on_pi "uptime | awk '{print \$10, \$11, \$12}'" 2>/dev/null || echo "unknown")
    local temp=$(execute_on_pi "vcgencmd measure_temp 2>/dev/null | cut -d= -f2" || echo "unknown")
    local disk=$(execute_on_pi "df -h / | tail -1 | awk '{print \$4}'" 2>/dev/null || echo "unknown")
    
    echo ""
    log_info "System Information:"
    echo "  Load Average: $load"
    echo "  Temperature: $temp"
    echo "  Free Disk: $disk"
}

# Function to start Pi Orchestrator
start_service() {
    if ! check_connection; then
        return 1
    fi
    
    log_info "Starting Pi Orchestrator..."
    
    # Check if already running
    if execute_on_pi "pgrep -f 'orchestrator' > /dev/null" 2>/dev/null; then
        log_warning "Pi Orchestrator is already running"
        return 0
    fi
    
    # Start the service in the background
    execute_on_pi "cd ~/PiOrchestrator && nohup make run-hex-dev > orchestrator.log 2>&1 &"
    
    # Wait a moment and check if it started
    sleep 3
    
    if execute_on_pi "pgrep -f 'orchestrator' > /dev/null" 2>/dev/null; then
        log_success "Pi Orchestrator started successfully"
    else
        log_error "Failed to start Pi Orchestrator"
        log_info "Check logs: ssh delicasa-pi 'tail -f ~/PiOrchestrator/orchestrator.log'"
        return 1
    fi
}

# Function to stop Pi Orchestrator
stop_service() {
    if ! check_connection; then
        return 1
    fi
    
    log_info "Stopping Pi Orchestrator..."
    
    if execute_on_pi "pgrep -f 'orchestrator' > /dev/null" 2>/dev/null; then
        execute_on_pi "pkill -f 'orchestrator'"
        log_success "Pi Orchestrator stopped"
    else
        log_warning "Pi Orchestrator was not running"
    fi
}

# Function to restart Pi Orchestrator
restart_service() {
    log_info "Restarting Pi Orchestrator..."
    stop_service
    sleep 2
    start_service
}

# Function to view logs
view_logs() {
    if ! check_connection; then
        return 1
    fi
    
    log_info "Viewing Pi Orchestrator logs..."
    execute_on_pi "tail -f ~/PiOrchestrator/orchestrator.log" 2>/dev/null || {
        log_warning "No logs found, showing system logs..."
        execute_on_pi "journalctl -u pi-orchestrator -f" 2>/dev/null || {
            log_error "No logs available"
        }
    }
}

# Function to deploy to Pi
deploy_to_pi() {
    if ! check_connection; then
        return 1
    fi
    
    log_info "Deploying Pi Orchestrator to Pi..."
    
    # Stop current service
    stop_service
    
    # Sync code (assuming we're in the project root)
    if [ -d "./PiOrchestrator" ]; then
        log_info "Syncing code to Pi..."
        rsync -avz --delete \
            -e "ssh -i $SSH_KEY_PATH -p $PI_SSH_PORT" \
            ./PiOrchestrator/ \
            "$PI_USERNAME@$PI_HOST:~/PiOrchestrator/"
        
        # Build on Pi
        log_info "Building on Pi..."
        execute_on_pi "cd ~/PiOrchestrator && make clean && make build"
        
        # Start service
        start_service
        
        log_success "Deployment complete"
    else
        log_error "PiOrchestrator directory not found in current path"
        return 1
    fi
}

# Function to open SSH session
ssh_connect() {
    log_info "Opening SSH connection to Pi..."
    ssh -i "$SSH_KEY_PATH" -p "$PI_SSH_PORT" "$PI_USERNAME@$PI_HOST"
}

# Help function
show_help() {
    echo "Pi Orchestrator Management Script"
    echo "================================="
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  status      Show Pi Orchestrator status"
    echo "  start       Start Pi Orchestrator service"
    echo "  stop        Stop Pi Orchestrator service"
    echo "  restart     Restart Pi Orchestrator service"
    echo "  logs        View Pi Orchestrator logs (press Ctrl+C to exit)"
    echo "  deploy      Deploy code to Pi and restart service"
    echo "  ssh         Open SSH connection to Pi"
    echo "  health      Check Pi connection and service health"
    echo "  help        Show this help message"
    echo ""
    echo "Configuration:"
    echo "  Pi Host: $PI_HOST"
    echo "  Username: $PI_USERNAME"
    echo "  SSH Port: $PI_SSH_PORT"
}

# Main execution
case "${1:-status}" in
    "status")
        get_status
        ;;
    "start")
        start_service
        ;;
    "stop")
        stop_service
        ;;
    "restart")
        restart_service
        ;;
    "logs")
        view_logs
        ;;
    "deploy")
        deploy_to_pi
        ;;
    "ssh")
        ssh_connect
        ;;
    "health")
        check_connection && get_status
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac