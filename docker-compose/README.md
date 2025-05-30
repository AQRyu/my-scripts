# Docker Compose Update Script

This script (`update.sh`) automates the process of updating Docker Compose services by pulling the latest images and restarting the services. It's designed to be callable from anywhere on your system.

## Prerequisites

*   **Docker:** Must be installed and running.
*   **Docker Compose:** Must be installed.
*   **Bash Shell:** The script is written for Bash.
*   **An existing Docker Compose project:** You need a `docker-compose.yml` file for the services you want to update.

## How it Works

The script performs the following actions:

1.  **Pulls Latest Images:** Executes `docker-compose pull` to download the newest versions of all images specified in your `docker-compose.yml` file.
2.  **Restarts Services:** Executes `docker-compose up -d --remove-orphans` to recreate and restart the services using the newly pulled images.
    *   If no containers are running for the project, it will start them.
    *   `--remove-orphans` cleans up containers for services that are no longer defined in the compose file.

## Installation

To make this script runnable from anywhere on your Ubuntu system:

1.  **Download the Script:**
    Open your terminal and download the script. For example, to download it to your home directory:
    ```bash
    curl -o ~/update.sh https://raw.githubusercontent.com/AQRyu/my-scripts/f77e2ecc0fa87d9b31a31f48064f979da5cf41f9/docker-compose/update.sh
    ```

2.  **Make it Executable:**
    ```bash
    chmod +x ~/update.sh
    ```

3.  **Move it to a Directory in Your PATH:**
    A common place for user-specific scripts is `~/bin` or `~/.local/bin`. We'll use `~/bin`.

    a.  Create the directory if it doesn't exist:
        ```bash
        mkdir -p ~/bin
        ```

    b.  If `~/bin` is not already in your PATH, add it. Edit your shell's configuration file (e.g., `~/.bashrc` for Bash, `~/.zshrc` for Zsh):
        ```bash
        nano ~/.bashrc
        ```
        Add these lines to the end of the file:
        ```bash
        # Add ~/bin to PATH
        if [ -d "$HOME/bin" ] ; then
            PATH="$HOME/bin:$PATH"
        fi
        ```
        Save the file (Ctrl+O, Enter, then Ctrl+X in nano).

    c.  Apply the changes to your current shell session:
        ```bash
        source ~/.bashrc
        ```
        Alternatively, open a new terminal window.

    d.  Move the script into `~/bin`. You can also rename it for convenience:
        ```bash
        mv ~/update.sh ~/bin/update-docker-compose
        ```
        Now you can run the script using the command `update-docker-compose`.

## Usage

You can now call the script (e.g., `update-docker-compose`) from any directory.

### Script Options

The script accepts the following command-line options:

*   `-f <compose_file>`: Specify the path to the `docker-compose.yml` file.
    *   Default: `docker-compose.yml` (looks in the current directory if not specified).
*   `-p <project_name>`: Specify the Docker Compose project name.
    *   Default: The base name of the current directory (`basename "$(pwd)"`).
*   `-h`: Display the help message.

### Examples

**1. Updating a project from within its directory:**

If your `docker-compose.yml` is in `/srv/my-app/` and you are currently in that directory:

```bash
cd /srv/my-app/
update-docker-compose
