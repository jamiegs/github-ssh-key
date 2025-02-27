# github-ssh-key
Script that downloads a key from Github and adds it to the current user's .ssh folder. This was written to give me an easy way to gain SSH access to homelab PCs without having to copy files around. I could add this one-line command to the cloud-init script.

## Usage

To use this script, run the following command, replacing `<GITHUB_USERNAME>` with the GitHub username whose public SSH key you want to add:

```bash
curl -s https://raw.githubusercontent.com/jamiegs/github-ssh-key/HEAD/ssh-auth-github-user.sh | bash -s <GITHUB_USERNAME>
```

## Description

This script performs the following steps:
1. Checks if the required commands (`curl`, `mktemp`, `grep`, `mkdir`, `mv`, `chmod`, `cat`) are installed.
2. Creates a temporary file to store the downloaded public key.
3. Downloads the public key from the specified GitHub user's account.
4. Validates the downloaded file to ensure it contains a valid SSH public key.
5. Ensures the `.ssh` directory exists in the user's home directory.
6. Moves the downloaded public key to the `.ssh` directory.
7. Sets appropriate permissions for the public key file.
8. Adds the public key to the `authorized_keys` file.
9. Sets appropriate permissions for the `authorized_keys` file.
10. Cleans up temporary files and prints a success message.

## Example

To add the public SSH key of the GitHub user `octocat` to your `authorized_keys` file, run:

```bash
curl -s https://raw.githubusercontent.com/jamiegs/github-ssh-key/HEAD/ssh-auth-github-user.sh | bash -s octocat
```

## Error Handling

The script includes error handling for the following scenarios:
- Missing GitHub username argument.
- Missing required commands.
- Failed creation of a temporary file.
- Failed download of the public key.
- Empty or invalid public key file.
- Failed creation of the `.ssh` directory.
- Failed move of the public key file.
- Failed setting of file permissions.
- Failed addition of the public key to the `authorized_keys` file.

## License

This project is licensed under the MIT License.

