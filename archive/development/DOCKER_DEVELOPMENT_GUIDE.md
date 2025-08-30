# DeliCasa Docker Development Environment

This guide covers the Docker Compose-based development environment for DeliCasa, designed for efficient local development of Next Client and Bridge Server while maintaining connection to the Pi Orchestrator running on actual Raspberry Pi hardware.

## 🏗️ Architecture Overview

### Development Services
- **Next Client** (Port 3000): React/Next.js frontend application
- **Bridge Server** (Port 8080): Cloudflare Worker emulated locally using Wrangler
- **Pi Orchestrator Manager** (Port 9000): SSH tunnel/proxy to actual Raspberry Pi

### Service Integration Pattern
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Next Client   │    │  Bridge Server  │    │ Pi Orchestrator │
│   (localhost    │    │   (localhost    │    │ (Raspberry Pi   │
│     :3000)      │    │     :8080)      │    │  192.168.1.100  │
│                 │    │                 │    │     :9000)      │
│  Development    │    │  Development    │    │   Production    │
│    Container    │    │    Container    │    │    Hardware     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Deployed      │
                    │   Services      │
                    │ (Typical Usage) │
                    └─────────────────┘
```

### Deployment Integration
During development, services typically connect to **deployed versions** rather than locally running services:
- Next Client → Deployed Bridge Server (https://bridgeserver.delicasa.workers.dev)
- Bridge Server → Pi Orchestrator on actual hardware (via SSH tunnel)
- All services → Deployed databases and cloud services

## 🚀 Quick Start

### 1. Initial Setup

```bash
# Clone and navigate to project root
cd /path/to/DeliCasa

# Run initial setup
./scripts/dev.sh setup
```

This will:
- Check Docker installation
- Create `.env` from `.env.example` (edit with your values)
- Optionally setup Pi Orchestrator SSH connection
- Build and start all services

### 2. Daily Development

```bash
# Start development environment
./scripts/dev.sh start

# Check status
./scripts/dev.sh status

# View logs
./scripts/dev.sh logs

# Stop environment
./scripts/dev.sh stop
```

### 3. Service-Specific Operations

```bash
# View specific service logs
./scripts/dev.sh logs next-client
./scripts/dev.sh logs bridge-server

# Execute commands in containers
./scripts/dev.sh exec next-client pnpm install
./scripts/dev.sh exec bridge-server pnpm run test

# Rebuild specific service
./scripts/dev.sh build next-client
```

## 📁 Project Structure

```
DeliCasa/
├── docker-compose.yml              # Main Docker Compose configuration
├── .env                           # Environment variables (create from .env.example)
├── .env.example                   # Environment template
├── scripts/
│   ├── dev.sh                     # Main development script
│   └── pi-manager/
│       ├── setup-pi-connection.sh # Pi SSH setup
│       └── pi-orchestrator-manager.sh # Pi management
├── next-client/
│   ├── Dockerfile.dev             # Next.js development container
│   └── ... (Next.js source code)
├── BridgeServer/
│   ├── Dockerfile.dev             # Bridge Server development container
│   └── ... (Bridge Server source code)
└── PiOrchestrator/
    └── ... (Pi Orchestrator source - deploys to actual Pi)
```

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

#### Core Service Configuration
```bash
# Next.js
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-here

# Database (typically remote)
DATABASE_URL="postgresql://user:pass@host:5432/db?sslmode=require"

# Service URLs (typically deployed versions)
BRIDGE_SERVER_URL=https://bridgeserver.delicasa.workers.dev
PI_ORCHESTRATOR_URL=http://192.168.1.100:9000
```

#### AWS Services
```bash
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
DELICASA_COGNITO_USER_POOL_ID=your-user-pool-id
DELICASA_COGNITO_APP_CLIENT_ID=your-app-client-id
```

#### Pi Orchestrator Connection
```bash
PI_HOST=192.168.1.100
PI_USERNAME=pi
PI_SSH_PORT=22
```

### Docker Compose Services

#### Next Client
- **Port**: 3000
- **Hot Reloading**: ✅ Enabled
- **Volume Mounts**: Source code, excluding node_modules and .next
- **Typical Connections**: Deployed Bridge Server, Real AWS services

#### Bridge Server
- **Port**: 8080
- **Development Mode**: Wrangler dev with local flag
- **Volume Mounts**: Source code, excluding node_modules
- **Typical Connections**: Real database, Real Cloudflare R2, Pi via SSH

#### Pi Orchestrator Manager
- **Port**: 9000 (proxy to Pi)
- **Function**: SSH tunnel to actual Raspberry Pi
- **Requirements**: SSH key setup for Pi access

## 🔗 Pi Orchestrator Integration

### SSH Setup

The Pi Orchestrator runs on actual Raspberry Pi hardware and is accessed via SSH:

```bash
# Setup SSH connection to Pi
./scripts/pi-manager/setup-pi-connection.sh

# Manage Pi Orchestrator service
./scripts/pi-manager/pi-orchestrator-manager.sh status
./scripts/pi-manager/pi-orchestrator-manager.sh start
./scripts/pi-manager/pi-orchestrator-manager.sh logs
```

### Pi Management Commands

```bash
# Quick access via main script
./scripts/dev.sh pi status
./scripts/dev.sh pi start
./scripts/dev.sh pi logs
./scripts/dev.sh pi deploy
./scripts/dev.sh pi ssh
```

### SSH Configuration

The setup script creates SSH config entry:
```
Host delicasa-pi
    HostName 192.168.1.100
    User pi
    Port 22
    IdentityFile ~/.ssh/id_rsa_delicasa_pi
```

## 🧪 Development Workflows

### 1. Frontend Development (Next Client)
```bash
# Start environment
./scripts/dev.sh start

# Work on frontend code
# (Files auto-reload in container)

# Install new packages
./scripts/dev.sh exec next-client pnpm add some-package

# Run tests
./scripts/dev.sh exec next-client pnpm test

# Check logs
./scripts/dev.sh logs next-client
```

### 2. Backend Development (Bridge Server)
```bash
# Start environment
./scripts/dev.sh start

# Work on Bridge Server code
# (Wrangler auto-reloads in container)

# Install new packages
./scripts/dev.sh exec bridge-server pnpm add some-package

# Run tests
./scripts/dev.sh exec bridge-server pnpm test

# Deploy to Cloudflare
./scripts/dev.sh exec bridge-server pnpm run deploy
```

### 3. Full-Stack Development
```bash
# Start all services
./scripts/dev.sh start

# Monitor all logs
./scripts/dev.sh logs

# In separate terminals:
# Terminal 1: Frontend work
./scripts/dev.sh logs next-client

# Terminal 2: Backend work
./scripts/dev.sh logs bridge-server

# Terminal 3: Pi monitoring
./scripts/dev.sh pi logs
```

### 4. Pi Orchestrator Development
```bash
# Connect to Pi for development
./scripts/dev.sh pi ssh

# On Pi: make changes and restart
cd ~/PiOrchestrator
make clean && make build
make run-hex-dev

# Or deploy from local machine
./scripts/dev.sh pi deploy
```

## 🔍 Debugging and Troubleshooting

### Common Issues

#### Services Won't Start
```bash
# Check Docker status
docker info

# Check environment configuration
cat .env

# Clean and rebuild
./scripts/dev.sh clean
./scripts/dev.sh start
```

#### Pi Connection Issues
```bash
# Test Pi connection
./scripts/dev.sh pi health

# Re-setup SSH connection
./scripts/pi-manager/setup-pi-connection.sh

# Manual SSH test
ssh -i ~/.ssh/id_rsa_delicasa_pi pi@192.168.1.100
```

#### Port Conflicts
```bash
# Check what's using ports
lsof -i :3000
lsof -i :8080
lsof -i :9000

# Stop conflicting services
./scripts/dev.sh stop
```

### Logging and Monitoring

```bash
# View all service logs
./scripts/dev.sh logs

# View specific service logs with timestamps
docker-compose logs -t -f next-client

# View Pi Orchestrator logs
./scripts/dev.sh pi logs

# Check service health
./scripts/dev.sh status
```

### Performance Optimization

#### Container Resource Usage
```bash
# Monitor container resource usage
docker stats

# Check container sizes
docker images | grep delicasa

# Cleanup unused resources
./scripts/dev.sh clean
```

#### Hot Reload Performance
- Node modules are excluded from volume mounts for performance
- Only source code directories are mounted
- Separate volumes for node_modules in each container

## 🚀 Deployment Integration

### Environment-Specific Configurations

#### Development (Default)
- Local containers for Next Client and Bridge Server
- Connect to deployed databases and services
- Pi Orchestrator on actual hardware via SSH

#### Local Testing
```bash
# Override to use all local services (rare)
export NEXT_PUBLIC_BRIDGE_WORKER_URL=http://localhost:8080
export NEXT_PUBLIC_PI_ORCHESTRATOR_URL=http://localhost:9000
./scripts/dev.sh restart
```

#### Production Testing
```bash
# Use all deployed services for integration testing
export BRIDGE_SERVER_URL=https://bridgeserver.delicasa.workers.dev
export PI_ORCHESTRATOR_URL=http://production-pi:9000
./scripts/dev.sh restart
```

### CI/CD Integration

The Docker setup supports CI/CD workflows:

```yaml
# Example GitHub Actions workflow
name: Development Environment Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Start development environment
        run: ./scripts/dev.sh start
      - name: Run tests
        run: |
          ./scripts/dev.sh exec next-client pnpm test
          ./scripts/dev.sh exec bridge-server pnpm test
      - name: Cleanup
        run: ./scripts/dev.sh clean
```

## 🔒 Security Considerations

### SSH Key Management
- Dedicated SSH key for Pi access: `~/.ssh/id_rsa_delicasa_pi`
- Keys are generated automatically but not shared in containers
- Pi access requires proper SSH key setup

### Environment Variables
- Sensitive variables in `.env` (excluded from version control)
- Production secrets not in development containers
- Use least-privilege AWS credentials for development

### Container Security
- Non-root users in all containers
- Minimal base images (Alpine Linux)
- No unnecessary ports exposed
- Health checks for service monitoring

## 📚 Advanced Usage

### Custom Development Configurations

#### Override Docker Compose
```bash
# Create docker-compose.override.yml for custom settings
version: '3.8'
services:
  next-client:
    ports:
      - "3001:3000"  # Custom port
    environment:
      - CUSTOM_VAR=value
```

#### Service-Specific Environment Files
```bash
# Create service-specific env files
# .env.next-client
# .env.bridge-server
# Reference in docker-compose.yml
```

### Multi-Developer Setup

#### Shared Pi Development
```bash
# Configure different Pi instances per developer
export PI_HOST=192.168.1.101  # Developer 1
export PI_HOST=192.168.1.102  # Developer 2
./scripts/dev.sh start
```

#### Port Customization
```bash
# Custom ports to avoid conflicts
export NEXT_CLIENT_PORT=3001
export BRIDGE_SERVER_PORT=8081
./scripts/dev.sh start
```

### Development Scripts Integration

The `scripts/dev.sh` script can be extended with custom commands:

```bash
# Add to scripts/dev.sh
case "$1" in
    "custom-command")
        # Your custom development workflow
        ;;
esac
```

## 🎯 Best Practices

### Development Workflow
1. **Start with `./scripts/dev.sh setup`** for new environments
2. **Use deployed services** for most development (faster, more realistic)
3. **Only run services locally** when actively developing that specific service
4. **Keep Pi Orchestrator on hardware** for realistic hardware testing
5. **Use `./scripts/dev.sh status`** to monitor environment health

### Container Management
1. **Regularly clean up** with `./scripts/dev.sh clean`
2. **Monitor resource usage** with `docker stats`
3. **Use specific service commands** rather than generic Docker commands
4. **Keep containers updated** by rebuilding periodically

### Pi Integration
1. **Setup SSH keys once** and maintain them
2. **Use Pi management scripts** rather than direct SSH
3. **Deploy to Pi frequently** to test hardware integration
4. **Monitor Pi logs** during development

## 🆘 Support and Troubleshooting

### Getting Help
```bash
# Show all available commands
./scripts/dev.sh help

# Pi management help
./scripts/dev.sh pi help

# Docker Compose help
docker-compose help
```

### Common Commands Reference
```bash
# Environment Management
./scripts/dev.sh setup          # Initial setup
./scripts/dev.sh start          # Start all services
./scripts/dev.sh stop           # Stop all services  
./scripts/dev.sh restart        # Restart all services
./scripts/dev.sh status         # Check status
./scripts/dev.sh clean          # Clean up resources

# Service Management
./scripts/dev.sh logs [service] # View logs
./scripts/dev.sh build [service] # Build services
./scripts/dev.sh exec <service> <cmd> # Execute commands

# Pi Management
./scripts/dev.sh pi status      # Pi status
./scripts/dev.sh pi start       # Start Pi service
./scripts/dev.sh pi logs        # Pi logs
./scripts/dev.sh pi deploy      # Deploy to Pi
./scripts/dev.sh pi ssh         # SSH to Pi
```

This Docker-based development environment provides a production-like setup while maintaining the flexibility needed for efficient development across the DeliCasa microservices architecture.