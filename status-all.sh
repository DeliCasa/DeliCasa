#!/usr/bin/env bash

# DeliCasa Repository Status Script
# This script shows the status of all DeliCasa repositories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}📊 DeliCasa Repository Status${NC}"
echo "================================================"

# Repository directories
REPOS=("BridgeServer" "NextClient" "PiOrchestrator" "EspCamV2" "Docs")

# Function to get detailed repository status
get_detailed_status() {
    local dir_name=$1
    
    if [ ! -d "$dir_name" ]; then
        echo -e "${RED}❌ $dir_name${NC}"
        echo "   Status: Not cloned"
        echo "   Action: Run 'bash clone-all.sh' to clone"
        echo ""
        return
    fi
    
    cd "$dir_name"
    
    if [ ! -d ".git" ]; then
        echo -e "${RED}❌ $dir_name${NC}"
        echo "   Status: Not a git repository"
        echo ""
        cd ..
        return
    fi
    
    # Git information
    local current_branch=$(git branch --show-current)
    local commit_hash=$(git rev-parse --short HEAD)
    local commit_message=$(git log -1 --format=%s)
    local commit_date=$(git log -1 --format=%cd --date=short)
    local commit_author=$(git log -1 --format=%an)
    local remote_url=$(git remote get-url origin 2>/dev/null || echo "No remote")
    
    # Check repository status
    local status_indicator="${GREEN}✅"
    local status_text="Clean"
    local has_uncommitted=false
    local behind_count=0
    local ahead_count=0
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        status_indicator="${YELLOW}🔄"
        status_text="Modified"
        has_uncommitted=true
    fi
    
    # Check if we're ahead/behind remote
    if git remote show origin &>/dev/null; then
        local remote_branch="origin/$current_branch"
        if git rev-parse --verify "$remote_branch" &>/dev/null; then
            behind_count=$(git rev-list --count HEAD.."$remote_branch" 2>/dev/null || echo "0")
            ahead_count=$(git rev-list --count "$remote_branch"..HEAD 2>/dev/null || echo "0")
            
            if [ "$behind_count" -gt 0 ]; then
                status_indicator="${YELLOW}⬇️"
                status_text="Behind remote ($behind_count commits)"
            elif [ "$ahead_count" -gt 0 ]; then
                status_indicator="${BLUE}⬆️"
                status_text="Ahead of remote ($ahead_count commits)"
            fi
        fi
    fi
    
    # Display repository info
    echo -e "$status_indicator ${CYAN}$dir_name${NC}"
    echo "   Branch: $current_branch"
    echo "   Commit: $commit_hash ($commit_date)"
    echo "   Author: $commit_author"
    echo "   Message: $commit_message"
    echo "   Status: $status_text"
    echo "   Remote: $remote_url"
    
    # Show uncommitted changes if any
    if [ "$has_uncommitted" = true ]; then
        echo -e "   ${YELLOW}Uncommitted changes:${NC}"
        git status --porcelain | head -10 | while read -r line; do
            echo "     $line"
        done
        local total_changes=$(git status --porcelain | wc -l)
        if [ "$total_changes" -gt 10 ]; then
            echo "     ... and $((total_changes - 10)) more"
        fi
    fi
    
    echo ""
    cd ..
}

# Function to show summary
show_summary() {
    echo -e "${GREEN}📈 Summary${NC}"
    echo "================================================"
    
    local total=0
    local cloned=0
    local clean=0
    local modified=0
    local behind=0
    local ahead=0
    
    for repo in "${REPOS[@]}"; do
        total=$((total + 1))
        
        if [ ! -d "$repo" ]; then
            continue
        fi
        
        cloned=$((cloned + 1))
        
        if [ -d "$repo/.git" ]; then
            cd "$repo"
            
            if git diff-index --quiet HEAD --; then
                clean=$((clean + 1))
            else
                modified=$((modified + 1))
            fi
            
            # Check remote status
            if git remote show origin &>/dev/null; then
                local current_branch=$(git branch --show-current)
                local remote_branch="origin/$current_branch"
                if git rev-parse --verify "$remote_branch" &>/dev/null; then
                    local behind_count=$(git rev-list --count HEAD.."$remote_branch" 2>/dev/null || echo "0")
                    local ahead_count=$(git rev-list --count "$remote_branch"..HEAD 2>/dev/null || echo "0")
                    
                    if [ "$behind_count" -gt 0 ]; then
                        behind=$((behind + 1))
                    elif [ "$ahead_count" -gt 0 ]; then
                        ahead=$((ahead + 1))
                    fi
                fi
            fi
            
            cd ..
        fi
    done
    
    echo "Total repositories: $total"
    echo "Cloned: $cloned"
    echo "Clean: $clean"
    echo "Modified: $modified"
    echo "Behind remote: $behind"
    echo "Ahead of remote: $ahead"
    
    if [ $modified -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}💡 Tip: Commit your changes before updating${NC}"
    fi
    
    if [ $behind -gt 0 ]; then
        echo -e "${YELLOW}💡 Tip: Run 'bash update-all.sh' to pull latest changes${NC}"
    fi
    
    if [ $((total - cloned)) -gt 0 ]; then
        echo -e "${YELLOW}💡 Tip: Run 'bash clone-all.sh' to clone missing repositories${NC}"
    fi
}

# Main execution
main() {
    for repo in "${REPOS[@]}"; do
        get_detailed_status "$repo"
    done
    
    show_summary
    
    echo ""
    echo "Available commands:"
    echo "  • bash clone-all.sh   - Clone all repositories"
    echo "  • bash update-all.sh  - Update all repositories"
    echo "  • bash setup-dev.sh   - Set up development environment"
}

# Run main function
main "$@"