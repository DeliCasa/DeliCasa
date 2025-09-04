#!/usr/bin/env bash

# Script to remove Claude as co-author from all repositories
# This uses git filter-repo to rewrite commit history and remove Co-authored-by: Claude lines

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🧹 Remove Claude Co-Author from Repositories${NC}"
echo "================================================"

# Repository directories
REPOS=("BridgeServer" "NextClient" "PiOrchestrator" "EspCamV2" "Docs")

# Function to check if git filter-repo is available
check_filter_repo() {
    if ! command -v git-filter-repo &> /dev/null; then
        echo -e "${YELLOW}⚠️  git-filter-repo not found, installing via pip...${NC}"
        if command -v pip3 &> /dev/null; then
            pip3 install --user git-filter-repo
        elif command -v pip &> /dev/null; then
            pip install --user git-filter-repo
        else
            echo -e "${RED}❌ pip not found. Please install git-filter-repo manually:${NC}"
            echo "   pip install git-filter-repo"
            echo "   or visit: https://github.com/newren/git-filter-repo"
            return 1
        fi
        
        # Add to PATH if needed
        export PATH="$HOME/.local/bin:$PATH"
        
        if ! command -v git-filter-repo &> /dev/null; then
            echo -e "${RED}❌ git-filter-repo installation failed${NC}"
            return 1
        fi
    fi
    
    echo -e "${GREEN}✅ git-filter-repo is available${NC}"
    return 0
}

# Function to remove Claude from a repository
remove_claude_from_repo() {
    local repo_name=$1
    
    if [ ! -d "$repo_name" ]; then
        echo -e "${YELLOW}⚠️  $repo_name not found${NC}"
        echo "   Run 'bash clone-all.sh' first"
        return 1
    fi
    
    echo -e "${BLUE}🔄 Processing $repo_name...${NC}"
    cd "$repo_name"
    
    if [ ! -d ".git" ]; then
        echo -e "${RED}❌ $repo_name is not a git repository${NC}"
        cd ..
        return 1
    fi
    
    # Check if there are any Claude co-author commits
    local claude_commits=$(git log --grep="Co-authored-by.*Claude" --oneline | wc -l)
    echo "   Found $claude_commits commits with Claude co-authorship"
    
    if [ "$claude_commits" -eq 0 ]; then
        echo -e "${GREEN}✅ No Claude co-authorship found in $repo_name${NC}"
        cd ..
        return 0
    fi
    
    # Create backup branch
    local backup_branch="backup-before-claude-removal-$(date +%Y%m%d-%H%M%S)"
    git branch "$backup_branch"
    echo "   Created backup branch: $backup_branch"
    
    # Create a fresh clone for git-filter-repo
    local temp_dir="../${repo_name}-temp-filter"
    if [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
    fi
    
    echo "   Creating fresh clone for filter-repo..."
    git clone . "$temp_dir"
    cd "$temp_dir"
    
    # Use git filter-repo to remove Claude co-authorship
    echo "   Removing Claude co-authorship from commit messages..."
    
    # Python script to remove Co-authored-by lines containing Claude
    cat > filter_script.py << 'PYTHON_EOF'
import re
import sys

def filter_message(original_message):
    # Remove any Co-authored-by lines that contain "Claude" (case insensitive)
    filtered_lines = []
    for line in original_message.decode('utf-8').split('\n'):
        if not re.match(r'^\s*Co-authored-by:.*Claude.*', line, re.IGNORECASE):
            filtered_lines.append(line)
    
    # Join lines back and remove extra whitespace
    result = '\n'.join(filtered_lines)
    # Remove multiple consecutive newlines
    result = re.sub(r'\n{3,}', '\n\n', result)
    # Remove trailing whitespace
    result = result.strip()
    
    return result.encode('utf-8')

# Read stdin and process
if __name__ == "__main__":
    original = sys.stdin.buffer.read()
    filtered = filter_message(original)
    sys.stdout.buffer.write(filtered)
PYTHON_EOF
    
    if git filter-repo --force --message-callback "$(cat filter_script.py)"; then
        echo -e "${GREEN}✅ Successfully removed Claude co-authorship${NC}"
        
        # Copy the filtered repository back
        cd ..
        rm -rf "${repo_name}-backup"
        mv "$repo_name" "${repo_name}-backup"
        mv "${repo_name}-temp-filter" "$repo_name"
        cd "$repo_name"
        
        # Verify the changes
        local remaining_claude=$(git log --grep="Co-authored-by.*Claude" --oneline | wc -l)
        echo "   Remaining Claude co-authorships: $remaining_claude"
        
        if [ "$remaining_claude" -eq 0 ]; then
            echo -e "${GREEN}✅ All Claude co-authorships removed from $repo_name${NC}"
        else
            echo -e "${YELLOW}⚠️  $remaining_claude Claude co-authorships remain in $repo_name${NC}"
        fi
        
    else
        echo -e "${RED}❌ Failed to filter $repo_name${NC}"
        cd ..
        return 1
    fi
    
    cd ..
    echo ""
    return 0
}

# Function to show Claude commits across all repos
show_claude_commits() {
    echo -e "${BLUE}📊 Claude Co-Authorship Analysis${NC}"
    echo "----------------------------------------"
    
    for repo in "${REPOS[@]}"; do
        if [ -d "$repo" ] && [ -d "$repo/.git" ]; then
            cd "$repo"
            local count=$(git log --grep="Co-authored-by.*Claude" --oneline | wc -l)
            if [ "$count" -gt 0 ]; then
                echo -e "${YELLOW}⚠️  $repo: $count commits${NC}"
                git log --grep="Co-authored-by.*Claude" --oneline | head -5
                if [ "$count" -gt 5 ]; then
                    echo "   ... and $((count - 5)) more"
                fi
            else
                echo -e "${GREEN}✅ $repo: clean${NC}"
            fi
            cd ..
            echo ""
        else
            echo -e "${RED}❌ $repo: not available${NC}"
        fi
    done
}

# Main execution
main() {
    if ! check_filter_repo; then
        exit 1
    fi
    
    echo ""
    echo "This will rewrite git history to remove Claude co-authorship from commits."
    echo -e "${RED}⚠️  This is a destructive operation that will change commit hashes!${NC}"
    echo ""
    
    # Show current state
    show_claude_commits
    
    read -p "Continue with Claude removal? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    
    # Process each repository
    failed_repos=()
    for repo in "${REPOS[@]}"; do
        if ! remove_claude_from_repo "$repo"; then
            failed_repos+=("$repo")
        fi
    done
    
    # Summary
    echo -e "${GREEN}🎉 Claude removal completed!${NC}"
    echo "================================================"
    
    if [ ${#failed_repos[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All repositories processed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to process: ${failed_repos[*]}${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}⚠️  Important next steps:${NC}"
    echo "1. Review the changes in each repository"
    echo "2. Force push to remote repositories: git push --force-with-lease origin main"
    echo "3. Coordinate with team members about the history rewrite"
    echo ""
    echo -e "${BLUE}📊 Final status:${NC}"
    show_claude_commits
}

# Run main function
main "$@"