# 🏠 DeliCasa - Smart Vending System

[![Project Status](https://img.shields.io/badge/Status-Production%20Ready-success)](#)
[![Architecture](https://img.shields.io/badge/Architecture-Multi--Repo-blue)](#)
[![Repositories](https://img.shields.io/badge/Repositories-6-green)](#)

> **🎯 IoT Vending + Multi-Role Web Platform + Real-time Communication = Complete Solution**

DeliCasa is a comprehensive IoT-based smart vending machine system featuring a multi-subdomain web platform, real-time device communication, and secure role-based access control for customers, administrators, and business partners.

## 🚀 Quick Start (New Setup)

This repository is a **wrapper/orchestration** repository that helps you manage all DeliCasa components together. It's **NOT a monorepo** - each component remains in its own repository for independent development.

### 1. Clone All Repositories
```bash
# Clone this wrapper repository
git clone https://github.com/DeliCasa/DeliCasa.git
cd DeliCasa

# Clone all component repositories
bash clone-all.sh
```

### 2. Set Up Development Environment
```bash
# Install dependencies and set up all repositories
bash setup-dev.sh

# Check status of all repositories
bash status-all.sh
```

### 3. Open Development Environment
```bash
# Open VS Code with all repositories in workspace
code DeliCasa.code-workspace
```

## 🔧 Repository Management

### Available Scripts

| Script | Description |
|--------|-------------|
| `bash clone-all.sh` | Clone all DeliCasa repositories |
| `bash update-all.sh` | Pull latest changes from all repositories |
| `bash status-all.sh` | Show status of all repositories |
| `bash setup-dev.sh` | Set up development environment |

### Repository Structure

```
DeliCasa/                    # 🏠 This wrapper repository
├── BridgeServer/            # 🌐 Real-time IoT communication server (Cloudflare Workers)
├── NextClient/              # 💻 Multi-subdomain web platform (Next.js 15)
├── PiOrchestrator/          # 🤖 Raspberry Pi device controller (Go)
├── EspCamV2/                # 📸 ESP32-CAM vision system (Arduino)
├── Docs/                    # 📚 Project documentation
├── clone-all.sh             # 📦 Repository orchestration scripts
├── update-all.sh            # 🔄 Update management
├── status-all.sh            # 📊 Status monitoring
├── setup-dev.sh             # 🔧 Development environment setup
└── DeliCasa.code-workspace  # 🗂️ VS Code workspace configuration
```

## 🏗️ Architecture Overview

### Component Repositories

#### 🌐 BridgeServer
- **Technology**: Hono.js + Cloudflare Workers + TypeScript
- **Purpose**: Central communication hub for IoT devices and web clients
- **Features**: HTTP/MQTT bridge, TRPC APIs, real-time communication
- **Repository**: [DeliCasa/BridgeServer](https://github.com/DeliCasa/BridgeServer)

#### 💻 NextClient
- **Technology**: Next.js 15 + TypeScript + Tailwind CSS
- **Purpose**: Multi-subdomain web platform with role-based access
- **Features**: Customer/Admin/Partner portals, AWS Cognito auth
- **Repository**: [DeliCasa/NextClient](https://github.com/DeliCasa/NextClient)

#### 🤖 PiOrchestrator
- **Technology**: Go + Hexagonal Architecture
- **Purpose**: Raspberry Pi device management and orchestration
- **Features**: Device control, sensor monitoring, communication bridge
- **Repository**: [DeliCasa/PiOrchestrator](https://github.com/DeliCasa/PiOrchestrator)

#### 📸 EspCamV2
- **Technology**: ESP32-CAM + Arduino + Computer Vision
- **Purpose**: Vision system for QR scanning and AI recognition
- **Features**: Real-time image capture, QR detection, ML inference
- **Repository**: [DeliCasa/EspCamV2](https://github.com/DeliCasa/EspCamV2)

#### 📚 Documentation
- **Purpose**: Centralized project documentation and specifications
- **Repository**: [DeliCasa/Docs](https://github.com/DeliCasa/Docs)

## 🌐 Live System

### Production URLs
- **Customer Portal**: https://customer.delicasa.workers.dev
- **Admin Panel**: https://admin.delicasa.workers.dev  
- **Partner Portal**: https://partner.delicasa.workers.dev
- **Bridge API**: https://bridgeserver.delicasa.workers.dev

### Test Accounts
- **Customer**: `customer-test@delicasa.com` / `CustomerTest123!`
- **Admin**: `admin-test@delicasa.com` / `AdminTest123!`
- **Partner**: `partner-test@delicasa.com` / `PartnerTest123!`

## 🛠️ Development Workflow

### Working on Specific Components

```bash
# Work on BridgeServer API
cd BridgeServer
pnpm dev:local                    # Start development server
pnpm test                         # Run tests
pnpm deploy                       # Deploy to Cloudflare Workers

# Work on NextClient web platform
cd NextClient
pnpm dev                          # Start development server
pnpm test:run                     # Run tests
pnpm deploy:all                   # Deploy all subdomains

# Work on PiOrchestrator IoT controller
cd PiOrchestrator
go run main.go                    # Start development
go test ./...                     # Run tests

# Work on EspCamV2 vision system
cd EspCamV2
# Use Arduino IDE or PlatformIO for development
```

### Keeping Everything Updated

```bash
# Check status of all repositories
bash status-all.sh

# Update all repositories to latest
bash update-all.sh

# Re-setup development environment if needed
bash setup-dev.sh
```

## ✨ Key Features

### 🌐 Multi-Repository Architecture
- **Independent Development** - Each team can work on their component independently
- **Version Control** - Each repository has its own versioning and release cycle
- **Technology Flexibility** - Each component uses the best technology for its purpose
- **Scalable Team Structure** - Different teams can own different repositories

### 🔗 Orchestration Benefits
- **Easy Setup** - One command to clone and set up everything
- **Unified Workspace** - VS Code workspace with all components
- **Status Management** - Monitor all repositories from one place
- **Development Scripts** - Automated environment setup and updates

### 🚀 Modern Stack
- **Edge Computing** - Cloudflare Workers for global performance
- **Type Safety** - Full TypeScript across web/API components
- **Hexagonal Architecture** - Clean separation of concerns in Go services
- **Real-time Communication** - MQTT bridge for IoT device integration

## 📋 Contributing

### Development Process
1. **Fork** the relevant component repository
2. **Clone** using the wrapper scripts: `bash clone-all.sh`
3. **Setup** development environment: `bash setup-dev.sh`
4. **Develop** in the specific component directory
5. **Test** your changes in the component repository
6. **Submit** pull request to the component repository

### Repository Maintenance
- Each component repository maintains its own CI/CD pipeline
- The wrapper repository is updated when new repositories are added/removed
- Documentation updates happen in the [Docs repository](https://github.com/DeliCasa/Docs)

## 🔧 Technology Stack

### Web Platform
- **Next.js 15** with App Router and TypeScript
- **Tailwind CSS** + shadcn/ui components  
- **Drizzle ORM** with PostgreSQL (Neon)
- **AWS Cognito** user management
- **Cloudflare Workers** edge deployment

### IoT & Communication
- **Hono.js** lightweight API framework
- **TRPC** end-to-end type safety
- **MQTT** real-time device communication
- **Go** Raspberry Pi orchestration (Hexagonal Architecture)
- **ESP32-CAM** computer vision hardware

---

> **Note**: This wrapper repository approach allows each component to be developed independently while providing easy orchestration for the complete system setup. It's designed for teams that want the benefits of microservices without the complexity of a monorepo.