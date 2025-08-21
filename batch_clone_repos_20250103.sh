#!/bin/bash

# Script to batch clone Git repositories on macOS
# Usage: ./batch_clone_repos_20250103.sh [options]

# Default values
INPUT_FILE="git_repos_ssh_urls.txt"
TARGET_DIRECTORY="$(pwd)"
PARALLEL_CLONE=false
MAX_PARALLEL_JOBS=3

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -f, --file FILE           Input file containing Git repository URLs (default: git_repos_ssh_urls.txt)"
    echo "  -d, --directory DIR       Target directory for cloning (default: current directory)"
    echo "  -p, --parallel            Enable parallel cloning"
    echo "  -j, --jobs NUM            Maximum number of parallel jobs (default: 3)"
    echo "  -h, --help                Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -f my_repos.txt -d /path/to/repos"
    echo "  $0 --parallel --jobs 5"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            INPUT_FILE="$2"
            shift 2
            ;;
        -d|--directory)
            TARGET_DIRECTORY="$2"
            shift 2
            ;;
        -p|--parallel)
            PARALLEL_CLONE=true
            shift
            ;;
        -j|--jobs)
            MAX_PARALLEL_JOBS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Function to clone a single repository
clone_repository() {
    local repo_url="$1"
    local target_dir="$2"
    
    # Extract repo name from SSH URL
    local repo_name=$(echo "$repo_url" | sed -E 's/.*[:/]([^/]+)\.git$/\1/')
    local target_path="$target_dir/$repo_name"
    
    # Skip if directory already exists
    if [[ -d "$target_path" ]]; then
        echo -e "${YELLOW}Repository '$repo_name' already exists at $target_path - Skipping${NC}"
        return 0
    fi
    
    echo -e "${CYAN}Cloning $repo_name...${NC}"
    
    # Clone the repository
    if git clone "$repo_url" "$target_path" >/dev/null 2>&1; then
        echo -e "${GREEN}Successfully cloned $repo_name${NC}"
        return 0
    else
        echo -e "${RED}Failed to clone $repo_name${NC}"
        return 1
    fi
}

# Function to wait for background jobs to complete
wait_for_jobs() {
    local max_jobs="$1"
    local current_jobs
    
    while true; do
        current_jobs=$(jobs -r | wc -l)
        if [[ $current_jobs -lt $max_jobs ]]; then
            break
        fi
        sleep 1
    done
}

# Create target directory if it doesn't exist
if [[ ! -d "$TARGET_DIRECTORY" ]]; then
    mkdir -p "$TARGET_DIRECTORY"
fi

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}Input file not found: $INPUT_FILE${NC}"
    exit 1
fi

# Read repository URLs and handle both formats
repos=()
while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]] && continue
    
    # Handle tab-separated format from collect_git_urls script
    if [[ "$line" == *$'\t'* ]]; then
        repo_url=$(echo "$line" | cut -f2)
    else
        # Handle plain URL format
        repo_url="$line"
    fi
    
    repos+=("$repo_url")
done < "$INPUT_FILE"

echo -e "${CYAN}Found ${#repos[@]} repositories to clone${NC}"
echo -e "${CYAN}Target directory: $TARGET_DIRECTORY${NC}"

if [[ "$PARALLEL_CLONE" == true ]]; then
    echo -e "${CYAN}Cloning repositories in parallel (max $MAX_PARALLEL_JOBS jobs)...${NC}"
    
    for repo in "${repos[@]}"; do
        # Wait if we've reached max parallel jobs
        wait_for_jobs "$MAX_PARALLEL_JOBS"
        
        # Start cloning in background
        clone_repository "$repo" "$TARGET_DIRECTORY" &
    done
    
    # Wait for all remaining jobs to complete
    wait
else
    # Sequential cloning
    for repo in "${repos[@]}"; do
        clone_repository "$repo" "$TARGET_DIRECTORY"
    done
fi

echo -e "${GREEN}Batch cloning completed!${NC}"
