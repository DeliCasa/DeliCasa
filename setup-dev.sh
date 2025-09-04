#!/usr/bin/env bash

# DeliCasa Development Environment Setup Script
# This script sets up the development environment for all repositories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔧 DeliCasa Development Environment Setup${NC}"
echo "================================================"

# Repository configurations
declare -A REPO_CONFIGS=(
    ["BridgeServer"]="pnpm"
    ["NextClient"]="pnpm"
    ["PiOrchestrator"]="go"
    ["EspCamV2"]="arduino"
    ["Docs"]="none"
)

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    local missing_tools=()
    
    # Check Node.js and pnpm
    if ! command -v node &> /dev/null; then
        missing_tools+=("Node.js")
    else
        echo "  ✅ Node.js: $(node --version)"
    fi
    
    if ! command -v pnpm &> /dev/null; then
        missing_tools+=("pnpm")
    else
        echo "  ✅ pnpm: $(pnpm --version)"
    fi
    
    # Check Go
    if ! command -v go &> /dev/null; then
        missing_tools+=("Go")
    else
        echo "  ✅ Go: $(go version | cut -d' ' -f3)"
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        missing_tools+=("Git")
    else
        echo "  ✅ Git: $(git --version | cut -d' ' -f3)"
    fi
    
    # Check GitHub CLI
    if ! command -v gh &> /dev/null; then
        missing_tools+=("GitHub CLI")
    else
        echo "  ✅ GitHub CLI: $(gh --version | head -1 | cut -d' ' -f3)"
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo ""
        echo -e "${RED}❌ Missing required tools: ${missing_tools[*]}${NC}"
        echo ""
        echo "Please install the missing tools:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "Node.js")
                    echo "  • Node.js: https://nodejs.org/"
                    ;;
                "pnpm")
                    echo "  • pnpm: npm install -g pnpm"
                    ;;
                "Go")
                    echo "  • Go: https://golang.org/doc/install"
                    ;;
                "Git")
                    echo "  • Git: https://git-scm.com/downloads"
                    ;;
                "GitHub CLI")
                    echo "  • GitHub CLI: https://cli.github.com/"
                    ;;
            esac
        done
        return 1
    fi
    
    echo ""
    return 0
}

# Function to setup a repository
setup_repo() {
    local repo_name=$1
    local setup_type=$2
    
    if [ ! -d "$repo_name" ]; then
        echo -e "${YELLOW}⚠️  $repo_name not found${NC}"
        echo "   Run 'bash clone-all.sh' first"
        return 1
    fi
    
    echo -e "${BLUE}🔧 Setting up $repo_name...${NC}"
    cd "$repo_name"
    
    case $setup_type in
        "pnpm")
            if [ ! -f "package.json" ]; then
                echo -e "${YELLOW}⚠️  No package.json found in $repo_name${NC}"
                cd ..
                return 1
            fi
            
            echo "   Installing pnpm dependencies..."
            if pnpm install; then
                echo -e "${GREEN}✅ Dependencies installed for $repo_name${NC}"
                
                # Run type checking if available
                if pnpm run type-check &> /dev/null; then
                    echo "   Running type check..."
                    pnpm run type-check
                fi
            else
                echo -e "${RED}❌ Failed to install dependencies for $repo_name${NC}"
                cd ..
                return 1
            fi
            ;;
        "go")
            if [ ! -f "go.mod" ]; then
                echo -e "${YELLOW}⚠️  No go.mod found in $repo_name${NC}"
                cd ..
                return 1
            fi
            
            echo "   Installing Go dependencies..."
            if go mod download && go mod tidy; then
                echo -e "${GREEN}✅ Go dependencies installed for $repo_name${NC}"
                
                # Try to build if main.go exists
                if [ -f "main.go" ] || [ -f "cmd/main.go" ]; then
                    echo "   Testing Go build..."
                    if go build -v ./...; then
                        echo -e "${GREEN}✅ Go build successful for $repo_name${NC}"
                    else
                        echo -e "${YELLOW}⚠️  Go build failed for $repo_name${NC}"
                    fi
                fi
            else
                echo -e "${RED}❌ Failed to install Go dependencies for $repo_name${NC}"
                cd ..
                return 1
            fi
            ;;
        "arduino")
            echo -e "${CYAN}ℹ️  $repo_name uses Arduino IDE${NC}"
            echo "   Please ensure Arduino IDE is installed for ESP32 development"
            echo "   Required libraries and board configurations should be documented in the repository"
            ;;
        "none")
            echo -e "${CYAN}ℹ️  $repo_name requires no special setup${NC}"
            ;;
        *)
            echo -e "${YELLOW}⚠️  Unknown setup type: $setup_type${NC}"
            ;;
    esac
    
    cd ..
    echo ""
    return 0
}

# Function to create VS Code workspace
create_workspace() {
    echo -e "${BLUE}📁 Creating VS Code workspace...${NC}"
    
    cat > "DeliCasa.code-workspace" << 'EOF'
{
    "folders": [
        {
            "name": "🏠 DeliCasa (Root)",
            "path": "."
        },
        {
            "name": "🌐 BridgeServer (API)",
            "path": "./BridgeServer"
        },
        {
            "name": "💻 NextClient (Web)",
            "path": "./NextClient"
        },
        {
            "name": "🤖 PiOrchestrator (IoT)",
            "path": "./PiOrchestrator"
        },
        {
            "name": "📸 EspCamV2 (Camera)",
            "path": "./EspCamV2"
        },
        {
            "name": "📚 Docs",
            "path": "./Docs"
        }
    ],
    "settings": {
        "typescript.preferences.includePackageJsonAutoImports": "auto",
        "typescript.suggest.autoImports": true,
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.fixAll": "explicit",
            "source.organizeImports": "explicit"
        },
        "files.exclude": {
            "**/node_modules": true,
            "**/dist": true,
            "**/.next": true,
            "**/target": true,
            "**/.git": false
        },
        "search.exclude": {
            "**/node_modules": true,
            "**/dist": true,
            "**/.next": true,
            "**/target": true
        }
    },
    "extensions": {
        "recommendations": [
            "ms-vscode.vscode-typescript-next",
            "bradlc.vscode-tailwindcss",
            "golang.go",
            "ms-vscode.vscode-json",
            "redhat.vscode-yaml",
            "ms-vscode.vscode-eslint"
        ]
    }
}
EOF

    echo -e "${GREEN}✅ VS Code workspace created: DeliCasa.code-workspace${NC}"
    echo ""
}

# Main execution
main() {
    if ! check_prerequisites; then
        exit 1
    fi
    
    echo -e "${BLUE}🚀 Setting up development environment...${NC}"
    echo ""
    
    # Setup each repository
    failed_repos=()
    for repo in "${!REPO_CONFIGS[@]}"; do
        if ! setup_repo "$repo" "${REPO_CONFIGS[$repo]}"; then
            failed_repos+=("$repo")
        fi
    done
    
    # Create VS Code workspace
    create_workspace
    
    # Summary
    echo -e "${GREEN}🎉 Development environment setup completed!${NC}"
    echo "================================================"
    
    if [ ${#failed_repos[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All repositories set up successfully${NC}"
    else
        echo -e "${RED}❌ Failed to set up: ${failed_repos[*]}${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}📋 Next steps:${NC}"
    echo "  1. Open VS Code workspace: code DeliCasa.code-workspace"
    echo "  2. For BridgeServer development:"
    echo "     cd BridgeServer && pnpm dev:local"
    echo "  3. For NextClient development:"
    echo "     cd NextClient && pnpm dev"
    echo "  4. For PiOrchestrator development:"
    echo "     cd PiOrchestrator && go run main.go"
    echo ""
    echo -e "${YELLOW}💡 Tip: Run 'bash status-all.sh' to check repository status${NC}"
}

# Run main function
main "$@"