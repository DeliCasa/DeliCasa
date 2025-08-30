# 🏠 DeliCasa - Smart Vending Machine System

[![Project Status](https://img.shields.io/badge/Status-Active%20Development-success)](./Docs/README.md)
[![Documentation](https://img.shields.io/badge/Documentation-Consolidated-blue)](./Docs/README.md)
[![Architecture](https://img.shields.io/badge/Architecture-Microservices-orange)](./Docs/01-TECHNICAL/Architecture.md)

> **Computer Vision + Secure Access = Effortless Vending**

DeliCasa is a comprehensive IoT-based smart vending machine system that combines computer vision, secure access control, and modern web technologies to create an effortless vending experience.

## 📚 Complete Documentation

**All documentation has been consolidated into the [Docs/](./Docs/) directory.**

- **[📖 Main Documentation Hub](./Docs/README.md)** - Central navigation for all documentation
- **[📋 Project Overview](./Docs/PROJECT_OVERVIEW.md)** - Complete project structure and component overview
- **[🏗️ System Architecture](./Docs/01-TECHNICAL/Architecture.md)** - Technical architecture and design

## 🚀 Project Components

### Frontend & Backend

- **[NextClient](./next-client/)** - Modern web frontend (Next.js + Cloudflare Pages)
- **[BridgeServer](./BridgeServer/)** - Backend API service (Cloudflare Workers)

### IoT & Hardware

- **[PiOrchestrator](./PiOrchestrator/)** - Raspberry Pi orchestration service (Go)
- **[EspCamV2](./EspCamV2/)** - ESP32-CAM firmware for image capture

## 🏁 Quick Start

### 🐳 Docker Development Environment (Recommended)

The fastest way to get started with DeliCasa development:

```bash
# Setup development environment
./scripts/dev.sh setup

# Start all services
./scripts/dev.sh start

# Check status
./scripts/dev.sh status

# View logs
./scripts/dev.sh logs
```

**Services Available:**
- **Next Client**: http://localhost:3000
- **Bridge Server**: http://localhost:8080  
- **Pi Orchestrator**: http://${PI_HOST}:9000 (on actual Pi hardware)

**📚 [Complete Docker Development Guide](./DOCKER_DEVELOPMENT_GUIDE.md)**

### For Developers

#### Traditional Development Setup
1. **Environment Setup**: See [Docs/02-OPERATIONS/Environment/](./Docs/02-OPERATIONS/Environment/)
2. **Development Scripts**: See [Docs/02-OPERATIONS/Scripts/](./Docs/02-OPERATIONS/Scripts/)
3. **Development Guide**: See [Docs/01-TECHNICAL/Integration/](./Docs/01-TECHNICAL/Integration/)
4. **Development Tools**: See [tools/](./tools/) - Testing and diagnostic utilities

#### VS Code Workspace

Open `DeliCasa.code-workspace` in VS Code for the complete development environment with:

- All projects organized in folders
- Integrated tasks for building and running services
- Debugging configurations for each service

#### Docker Commands Quick Reference
```bash
# Development Environment Management
./scripts/dev.sh start          # Start all services
./scripts/dev.sh stop           # Stop all services
./scripts/dev.sh restart        # Restart all services
./scripts/dev.sh logs [service] # View logs
./scripts/dev.sh status         # Check service status

# Pi Orchestrator Management
./scripts/dev.sh pi status      # Check Pi status
./scripts/dev.sh pi start       # Start Pi service
./scripts/dev.sh pi ssh         # SSH to Pi
./scripts/dev.sh pi deploy      # Deploy code to Pi

# Service-Specific Operations  
./scripts/dev.sh exec next-client pnpm install
./scripts/dev.sh exec bridge-server pnpm test
./scripts/dev.sh build [service]
```

### Cloudflare-Native Development

All services are deployed on Cloudflare infrastructure:

- **Next.js Client**: Deployed on Cloudflare Pages
- **Bridge Server**: Deployed on Cloudflare Workers  
- **Development**: Docker Compose with deployed service integration

### For Stakeholders

- **[Business Overview](./Docs/00-CORE/Business-Model.md)** - Value proposition and business model
- **[User Stories](./Docs/00-CORE/User-Stories.md)** - Customer journey and use cases
- **[Project Management](./Docs/02-OPERATIONS/Project-Management.md)** - Timeline and progress tracking

## 📊 Key Features

- **Smart Access Control** - Computer vision-based user recognition
- **Modern Web Interface** - Responsive React/Next.js frontend
- **Edge Computing** - Cloudflare Workers for global performance
- **IoT Integration** - MQTT-based device communication
- **Real-time Processing** - Live camera feeds and instant processing
- **Secure Architecture** - End-to-end encryption and authentication

## 🔧 Technology Stack

- **Frontend**: Next.js, React, TypeScript, Cloudflare Pages
- **Backend**: Cloudflare Workers, TypeScript, Drizzle ORM
- **IoT Services**: Go (Hexagonal Architecture), MQTT
- **Hardware**: Raspberry Pi, ESP32-CAM
- **Database**: PostgreSQL with edge caching
- **Deployment**: Cloudflare infrastructure

---

> **Note**: This project structure has been recently consolidated and cleaned up. All documentation is now centralized in the `Docs/` directory for better organization and maintainability.
