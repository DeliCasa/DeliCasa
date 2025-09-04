#!/usr/bin/env bash

# DeliCasa Update All Repositories Script
# This script updates all existing DeliCasa repositories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔄 DeliCasa Repository Update${NC}"
echo "================================================"

# Repository directories
REPOS=("BridgeServer" "NextClient" "PiOrchestrator" "EspCamV2" "Docs")

# Function to update a repository
update_repo() {
    local dir_name=$1
    
    if [ ! -d "$dir_name" ]; then
        echo -e "${YELLOW}⚠️  Directory $dir_name does not exist${NC}"
        echo -e "   Run 'clone-all.sh' first to clone repositories"
        return 1
    fi
    
    echo -e "${BLUE}🔄 Updating $dir_name...${NC}"
    cd "$dir_name"
    
    # Check if it's a git repository
    if [ ! -d ".git" ]; then
        echo -e "${RED}❌ $dir_name is not a git repository${NC}"
        cd ..
        return 1
    fi
    
    # Get current branch
    current_branch=$(git branch --show-current)
    echo "   Current branch: $current_branch"
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo -e "${YELLOW}⚠️  $dir_name has uncommitted changes${NC}"
        git status --porcelain
        echo "   Skipping update to avoid conflicts"
        cd ..
        return 0
    fi
    
    # Pull latest changes
    if git pull origin "$current_branch"; then
        echo -e "${GREEN}✅ Successfully updated $dir_name${NC}"
    else
        echo -e "${RED}❌ Failed to update $dir_name${NC}"
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# Function to show repository status
show_repo_status() {
    local dir_name=$1
    
    if [ ! -d "$dir_name" ]; then
        echo -e "  ${RED}❌ $dir_name (not cloned)${NC}"
        return
    fi
    
    cd "$dir_name"
    
    if [ ! -d ".git" ]; then
        echo -e "  ${RED}❌ $dir_name (not a git repository)${NC}"
        cd ..
        return
    fi
    
    local current_branch=$(git branch --show-current)
    local commit_hash=$(git rev-parse --short HEAD)
    local commit_date=$(git log -1 --format=%cd --date=short)
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo -e "  ${YELLOW}🔄 $dir_name${NC} ($current_branch @ $commit_hash, $commit_date) ${YELLOW}[modified]${NC}"
    else
        echo -e "  ${GREEN}✅ $dir_name${NC} ($current_branch @ $commit_hash, $commit_date)"
    fi
    
    cd ..
}

# Main execution
main() {
    echo "This will update all existing DeliCasa repositories."
    echo ""
    
    # Show current status
    echo -e "${BLUE}📊 Current Repository Status:${NC}"
    for repo in "${REPOS[@]}"; do
        show_repo_status "$repo"
    done
    echo ""
    
    read -p "Continue with update? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    
    # Update all repositories
    failed_repos=()
    for repo in "${REPOS[@]}"; do
        if ! update_repo "$repo"; then
            failed_repos+=("$repo")
        fi
        echo ""
    done
    
    # Summary
    echo -e "${GREEN}🎉 Repository update completed!${NC}"
    echo "================================================"
    
    if [ ${#failed_repos[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All repositories updated successfully${NC}"
    else
        echo -e "${RED}❌ Failed to update: ${failed_repos[*]}${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}📊 Updated Repository Status:${NC}"
    for repo in "${REPOS[@]}"; do
        show_repo_status "$repo"
    done
}

# Run main function
main "$@"