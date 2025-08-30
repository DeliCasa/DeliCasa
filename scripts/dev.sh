#!/bin/bash

# DeliCasa Development Environment Manager
# This script helps manage the Docker Compose development environment

set -e

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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root
cd "$PROJECT_ROOT"

# Check if .env file exists
check_env() {
    if [ ! -f ".env" ]; then
        log_warning ".env file not found"
        if [ -f ".env.example" ]; then
            log_info "Creating .env from .env.example..."
            cp .env.example .env
            log_warning "Please edit .env with your actual values before starting services"
            return 1
        else
            log_error ".env.example not found. Please create environment configuration."
            return 1
        fi
    fi
    log_success ".env file found"
    return 0
}

# Check Docker and Docker Compose availability
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker not found. Please install Docker."
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker daemon not running. Please start Docker."
        return 1
    fi
    
    log_success "Docker is available and running"
    return 0
}

# Function to setup Pi connection
setup_pi() {
    log_info "Setting up Pi Orchestrator connection..."
    if [ -f "./scripts/pi-manager/setup-pi-connection.sh" ]; then
        ./scripts/pi-manager/setup-pi-connection.sh
    else
        log_error "Pi setup script not found"
        return 1
    fi
}

# Function to start development environment
start_dev() {
    log_info "Starting DeliCasa development environment..."
    
    # Check prerequisites
    if ! check_docker || ! check_env; then
        return 1
    fi
    
    # Build and start services
    log_info "Building and starting services..."
    docker-compose up --build -d
    
    # Wait for services to be ready
    log_info "Waiting for services to be ready..."
    sleep 10
    
    # Check service health
    log_info "Checking service health..."
    
    # Check Next Client
    if curl -f http://localhost:3000/api/health &>/dev/null; then
        log_success "Next Client is healthy (http://localhost:3000)"
    else
        log_warning "Next Client health check failed"
    fi
    
    # Check Bridge Server
    if curl -f http://localhost:8080/health &>/dev/null; then
        log_success "Bridge Server is healthy (http://localhost:8080)"
    else
        log_warning "Bridge Server health check failed"
    fi
    
    # Check Pi connection
    if ./scripts/pi-manager/pi-orchestrator-manager.sh health &>/dev/null; then
        log_success "Pi Orchestrator is accessible"
    else
        log_warning "Pi Orchestrator health check failed - check connection"
    fi
    
    log_success "Development environment started!"
    log_info "Services available at:"
    echo "  • Next Client:     http://localhost:3000"
    echo "  • Bridge Server:   http://localhost:8080"
    echo "  • Pi Orchestrator: http://\${PI_HOST}:9000"
}

# Function to stop development environment
stop_dev() {
    log_info "Stopping DeliCasa development environment..."
    docker-compose down
    log_success "Development environment stopped"
}

# Function to restart development environment
restart_dev() {
    log_info "Restarting DeliCasa development environment..."
    stop_dev
    start_dev
}

# Function to show logs
show_logs() {
    local service="${1:-}"
    
    if [ -n "$service" ]; then
        log_info "Showing logs for $service..."
        docker-compose logs -f "$service"
    else
        log_info "Showing all service logs..."
        docker-compose logs -f
    fi
}

# Function to show status
show_status() {
    log_info "DeliCasa Development Environment Status"
    echo "======================================"
    
    # Docker Compose status
    if docker-compose ps | grep -q "Up"; then
        log_success "Docker services are running:"
        docker-compose ps
    else
        log_warning "Docker services are not running"
    fi
    
    echo ""
    
    # Pi Orchestrator status
    log_info "Pi Orchestrator Status:"
    ./scripts/pi-manager/pi-orchestrator-manager.sh status
}

# Function to clean up development environment
clean_dev() {
    log_warning "Cleaning up development environment..."
    echo "This will:"
    echo "  • Stop all containers"
    echo "  • Remove containers and networks"
    echo "  • Remove unused images"
    echo "  • Remove volumes (optional)"
    echo ""
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Stopping and removing containers..."
        docker-compose down --remove-orphans
        
        log_info "Removing unused images..."
        docker image prune -f
        
        read -p "Remove volumes? This will delete all data (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down --volumes
            docker volume prune -f
        fi
        
        log_success "Cleanup complete"
    else
        log_info "Cleanup cancelled"
    fi
}

# Function to run development commands
dev_exec() {
    local service="$1"
    shift
    local cmd="$*"
    
    if [ -z "$service" ] || [ -z "$cmd" ]; then
        log_error "Usage: $0 exec <service> <command>"
        log_info "Available services: next-client, bridge-server"
        return 1
    fi
    
    log_info "Executing '$cmd' in $service..."
    docker-compose exec "$service" $cmd
}

# Function to build specific service
build_service() {
    local service="${1:-}"
    
    if [ -n "$service" ]; then
        log_info "Building $service..."
        docker-compose build "$service"
    else
        log_info "Building all services..."
        docker-compose build
    fi
    
    log_success "Build complete"
}

# Function to setup development environment from scratch
setup_dev() {
    log_info "Setting up DeliCasa development environment from scratch..."
    
    # Check prerequisites
    if ! check_docker; then
        log_error "Please install Docker first"
        return 1
    fi
    
    # Setup environment
    if ! check_env; then
        log_warning "Please configure .env file before continuing"
        return 1
    fi
    
    # Setup Pi connection
    read -p "Setup Pi Orchestrator connection? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_pi
    fi
    
    # Build and start
    start_dev
    
    log_success "Development environment setup complete!"
}

# Help function
show_help() {
    echo "DeliCasa Development Environment Manager"
    echo "======================================="
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  start           Start development environment"
    echo "  stop            Stop development environment"
    echo "  restart         Restart development environment"
    echo "  status          Show environment status"
    echo "  logs [service]  Show logs (optionally for specific service)"
    echo "  build [service] Build services (optionally specific service)"
    echo "  exec <service> <cmd>  Execute command in service container"
    echo "  clean           Clean up development environment"
    echo "  setup           Setup development environment from scratch"
    echo "  pi              Manage Pi Orchestrator (shortcut to pi-orchestrator-manager.sh)"
    echo "  help            Show this help message"
    echo ""
    echo "Services:"
    echo "  next-client     Next.js frontend application"
    echo "  bridge-server   Bridge Server API"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start all services"
    echo "  $0 logs next-client         # Show Next.js logs"
    echo "  $0 exec next-client pnpm install  # Install dependencies in Next.js"
    echo "  $0 pi status                # Check Pi Orchestrator status"
    echo ""
    echo "For Pi Orchestrator management:"
    echo "  $0 pi [status|start|stop|restart|logs|deploy|ssh|health]"
}

# Main execution
case "${1:-help}" in
    "start")
        start_dev
        ;;
    "stop")
        stop_dev
        ;;
    "restart")
        restart_dev
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "${2:-}"
        ;;
    "build")
        build_service "${2:-}"
        ;;
    "exec")
        dev_exec "${2:-}" "${@:3}"
        ;;
    "clean")
        clean_dev
        ;;
    "setup")
        setup_dev
        ;;
    "pi")
        ./scripts/pi-manager/pi-orchestrator-manager.sh "${@:2}"
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