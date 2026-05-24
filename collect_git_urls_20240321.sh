#!/bin/bash

# Default parameters
ROOT_PATH="${1:-$(pwd)}"
DOWNLOADS_DIR="$HOME/Downloads"
OUTPUT_FILE="$DOWNLOADS_DIR/git_repo_list_$(date '+%Y%m%d_%H%M').txt"

# Function to get Git remote URL
get_git_remote_url() {
    local repo_path="$1"
    local remote_url
    
    # Save current directory and change to repo path
    pushd "$repo_path" > /dev/null
    
    if remote_url=$(git config --get remote.origin.url 2>/dev/null); then
        # Convert HTTPS URLs to SSH format if needed
        if [[ $remote_url =~ ^https://github\.com/(.+)/(.+)\.git$ ]]; then
            remote_url="git@github.com:${BASH_REMATCH[1]}/${BASH_REMATCH[2]}.git"
        fi
        echo "$remote_url"
    fi
    
    # Return to original directory
    popd > /dev/null
}

echo "Searching for Git repositories in: $ROOT_PATH"

# Create Downloads directory if it doesn't exist
mkdir -p "$DOWNLOADS_DIR"

# Find all .git directories and process them
while IFS= read -r -d '' git_dir; do
    repo_path="$(dirname "$git_dir")"
    if remote_url=$(get_git_remote_url "$repo_path"); then
        echo "Repository: $repo_path"
        echo "SSH URL: $remote_url"
        echo
        # Save to file
        {
            echo "Repository: $repo_path"
            echo "SSH URL: $remote_url"
            echo
        } >> "$OUTPUT_FILE"
    fi
done < <(find "$ROOT_PATH" -name ".git" -type d -print0)

# Check if we found any repositories
if [ ! -s "$OUTPUT_FILE" ]; then
    echo "No Git repositories found."
else
    echo "Results saved to: $OUTPUT_FILE"
fi
