#!/usr/bin/env bash

# DeliCasa Repository Orchestration Script
# This script clones all DeliCasa repositories into the correct structure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🏠 DeliCasa Repository Orchestration${NC}"
echo "================================================"

# Repository configuration
declare -A REPOS=(
    ["BridgeServer"]="DeliCasa/BridgeServer"
    ["NextClient"]="DeliCasa/NextClient"
    ["PiOrchestrator"]="DeliCasa/PiOrchestrator"
    ["EspCamV2"]="DeliCasa/EspCamV2"
    ["Docs"]="DeliCasa/Docs"
)

# Function to clone a repository
clone_repo() {
    local dir_name=$1
    local repo_path=$2
    
    if [ -d "$dir_name" ]; then
        echo -e "${YELLOW}⚠️  Directory $dir_name already exists${NC}"
        echo -e "   Use 'update-all.sh' to update existing repositories"
        return 0
    fi
    
    echo -e "${BLUE}📦 Cloning $repo_path into $dir_name...${NC}"
    if gh repo clone "$repo_path" "$dir_name"; then
        echo -e "${GREEN}✅ Successfully cloned $dir_name${NC}"
    else
        echo -e "${RED}❌ Failed to clone $dir_name${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo "This will clone all DeliCasa repositories into the current directory."
    echo ""
    
    # Check if gh is installed and authenticated
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI (gh) is not installed${NC}"
        echo "Please install it from: https://cli.github.com/"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI is not authenticated${NC}"
        echo "Please run: gh auth login"
        exit 1
    fi
    
    echo "Repositories to clone:"
    for dir_name in "${!REPOS[@]}"; do
        echo "  • $dir_name <- ${REPOS[$dir_name]}"
    done
    echo ""
    
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    
    # Clone all repositories
    failed_repos=()
    for dir_name in "${!REPOS[@]}"; do
        if ! clone_repo "$dir_name" "${REPOS[$dir_name]}"; then
            failed_repos+=("$dir_name")
        fi
    done
    
    # Summary
    echo ""
    echo -e "${GREEN}🎉 Repository cloning completed!${NC}"
    echo "================================================"
    
    if [ ${#failed_repos[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All repositories cloned successfully${NC}"
    else
        echo -e "${RED}❌ Failed to clone: ${failed_repos[*]}${NC}"
        echo "You may need to check permissions or network connectivity."
    fi
    
    echo ""
    echo "Next steps:"
    echo "  • Run 'bash update-all.sh' to pull latest changes"
    echo "  • Run 'bash status-all.sh' to check repository status"
    echo "  • Run 'bash setup-dev.sh' to set up development environment"
}

# Run main function
main "$@"