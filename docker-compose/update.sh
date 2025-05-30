#!/bin/bash

set -euo pipefail

# Constants
DEFAULT_COMPOSE_FILE="docker-compose.yml"
DEFAULT_PROJECT_NAME=$(basename "$(pwd)")
DOCKER_COMMAND="docker"
DOCKER_COMPOSE_COMMAND="docker-compose"

# Function to display installation instructions
show_installation_instructions() {
  cat <<EOF
Please install Docker Compose using one of the methods below:

1. Using pip (if you have Python and pip installed):
   pip install docker-compose

2. On Linux (using apt - Debian/Ubuntu):
   sudo apt-get update
   sudo apt-get install docker-compose

3. On macOS (using Homebrew):
   brew install docker-compose

Alternatively, if you have Docker installed, you can use the 'docker compose' command (Docker Compose V2).

Refer to the Docker Compose documentation for more detailed instructions:
https://docs.docker.com/compose/install/
EOF
}

# Function to check if Docker Compose is installed
check_docker_compose() {
  if command -v "$DOCKER_COMPOSE_COMMAND" &>/dev/null; then
    DOCKER_COMPOSE_COMMAND="$DOCKER_COMPOSE_COMMAND"
  elif command -v "$DOCKER_COMMAND" &>/dev/null && "$DOCKER_COMMAND" compose version &>/dev/null; then
    DOCKER_COMPOSE_COMMAND="$DOCKER_COMMAND compose"
  else
    echo "Error: Neither docker-compose nor docker compose (Docker Compose V2) is installed."
    show_installation_instructions
    exit 1
  fi
}

# Function to validate the compose file
validate_compose_file() {
  local compose_file=$1
  if [[ ! -f "$compose_file" ]]; then
    echo "Error: Docker Compose file '$compose_file' not found."
    exit 1
  fi
}

# Function to execute Docker Compose commands
execute_docker_compose() {
  local compose_file=$1
  local project_name=$2
  local command=$3
  $DOCKER_COMPOSE_COMMAND -f "$compose_file" -p "$project_name" $command
}

# Function to pull the latest images
pull_latest_images() {
  local compose_file=$1
  local project_name=$2

  echo "Pulling latest images for project '$project_name' using compose file '$compose_file'..."
  validate_compose_file "$compose_file"
  execute_docker_compose "$compose_file" "$project_name" "pull"
  echo "Successfully pulled latest images."
}

# Function to restart containers
restart_containers() {
  local compose_file=$1
  local project_name=$2

  echo "Restarting containers for project '$project_name' using compose file '$compose_file'..."
  validate_compose_file "$compose_file"

  # Check for running containers
  local running_containers
  running_containers=$($DOCKER_COMPOSE_COMMAND -f "$compose_file" -p "$project_name" ps -q 2>/dev/null)

  if [[ -n "$running_containers" ]]; then
    echo "Running containers found. Restarting..."
    execute_docker_compose "$compose_file" "$project_name" "up -d --remove-orphans"
  else
    echo "No running containers found. Starting services..."
    execute_docker_compose "$compose_file" "$project_name" "up -d"
  fi

  echo "Successfully restarted containers."
}

# Function to display usage
usage() {
  cat <<EOF
Usage: $0 [options]
Options:
  -p <project_name>  Specify the Docker Compose project name (default: $(basename "$(pwd)"))
  -f <compose_file>  Specify the path to the docker-compose.yml file (default: docker-compose.yml)
  -h                 Display this help message
EOF
}

# Parse command-line arguments
COMPOSE_FILE="$DEFAULT_COMPOSE_FILE"
PROJECT_NAME="$DEFAULT_PROJECT_NAME"

while getopts ":p:f:h" opt; do
  case $opt in
    p) PROJECT_NAME="$OPTARG" ;;
    f) COMPOSE_FILE="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Error: Option -$OPTARG requires an argument." >&2; usage; exit 1 ;;
    ?) echo "Error: Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

# Shift off the options to get to any remaining arguments
shift $((OPTIND - 1))

# Check for extraneous arguments
if [[ $# -gt 0 ]]; then
  echo "Error: Too many arguments." >&2
  usage
  exit 1
fi

# Sanity check for project name
if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: Project name cannot be empty."
  exit 1
fi

# Main logic
check_docker_compose
pull_latest_images "$COMPOSE_FILE" "$PROJECT_NAME"
restart_containers "$COMPOSE_FILE" "$PROJECT_NAME"

echo "Docker Compose services updated and restarted."