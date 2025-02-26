#!/bin/bash

# Description:
# This script downloads a public SSH key from a specified GitHub user's account
# and adds it to the authorized_keys file on the local machine. It performs the
# following steps:
# 1. Checks if the required commands (curl, mktemp, grep, mkdir, mv, chmod, cat) are installed.
# 2. Creates a temporary file to store the downloaded public key.
# 3. Downloads the public key from the GitHub user's account.
# 4. Validates the downloaded file to ensure it contains a valid SSH public key.
# 5. Ensures the .ssh directory exists in the user's home directory.
# 6. Moves the downloaded public key to the .ssh directory.
# 7. Sets appropriate permissions for the public key file.
# 8. Adds the public key to the authorized_keys file.
# 9. Sets appropriate permissions for the authorized_keys file.
# 10. Cleans up temporary files and prints a success message.

# Exit immediately if a command exits with a non-zero status
set -e

# Function to clean up temporary files
cleanup() {
    if [ -f "$temp_file_path" ]; then
        rm -f "$temp_file_path"
    fi
}
trap cleanup EXIT

# Get GitHub username from the command line
if [ $# -eq 0 ]; then
    printf "No arguments provided. Please provide a GitHub username.\n"
    exit 1
fi
github_user=$1

# Check if required commands are installed
for cmd in curl mktemp grep mkdir mv chmod cat; do
    if ! command -v $cmd &> /dev/null; then
        printf "%s could not be found. Please install %s.\n" "$cmd" "$cmd"
        exit 1
    fi
done

key_file_name=gh_${github_user}_key.pub
# Create a temporary file
temp_file_path=$(mktemp /tmp/${key_file_name}.XXXXXX)

# Download the public key from GitHub
download_url="https://github.com/${github_user}.keys"
printf "Downloading public key from %s\n" "$download_url"
curl -s "$download_url" -o "$temp_file_path"

# Check if the download was successful and the file is not empty
if [ ! -s "$temp_file_path" ]; then
    printf "The downloaded file is empty. Please check the URL or your internet connection.\n"
    exit 1
fi

# Check if the file contains a valid SSH public key
if ! grep -q "ssh-" "$temp_file_path"; then
    printf "The downloaded file does not contain a valid SSH public key.\n"
    exit 1
fi

# Ensure the .ssh directory exists
ssh_dir="$HOME/.ssh"
ssh_file_path="$ssh_dir/${key_file_name}"

if [ ! -d "$ssh_dir" ]; then
    printf "Creating .ssh directory in home directory.\n"
    mkdir -p "$ssh_dir"
fi

# Move the file to ~/.ssh
mv "$temp_file_path" "$ssh_file_path"

# Set permissions for the file
chmod 644 "$ssh_file_path"

#comment for end of line 
auth_keys_comment="# ${github_user} github public keys added by ssh-auth-github-user.sh script:"
echo "$auth_keys_comment" >> "$ssh_dir/authorized_keys"

# Add the public key to the authorized_keys file
printf "Adding the public key to the authorized_keys file.\n"
cat "$ssh_file_path" >> "$ssh_dir/authorized_keys"

# Set permissions for the authorized_keys file
chmod 600 "$ssh_dir/authorized_keys"

# Print success message
printf "Public key added to authorized_keys file successfully.\n"