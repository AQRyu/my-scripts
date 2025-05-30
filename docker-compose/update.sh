#!/bin/bash

set -euo pipefail

# Define default values and constants
COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME=$(basename "$(pwd)")
DOCKER_COMPOSE_COMMAND="docker-compose"
DOCKER_COMMAND="docker" # Define docker command

# Function to display installation instructions
show_installation_instructions() {
  echo "Please install Docker Compose using one of the methods below:"
  echo
  echo "1. Using pip (if you have Python and pip installed):"
  echo "   pip install docker-compose"
  echo
  echo "2. On Linux (using apt - Debian/Ubuntu):"
  echo "   sudo apt-get update"
  echo "   sudo apt-get install docker-compose"
  echo
  echo "3. On macOS (using Homebrew):"
  echo "   brew install docker-compose"
  echo
  echo "Alternatively, if you have Docker installed, you can use the 'docker compose' command (Docker Compose V2)."
  echo
  echo "Refer to the Docker Compose documentation for more detailed instructions:"
  echo "https://docs.docker.com/compose/install/"
}

# Check if docker-compose or docker compose is installed
if ! command -v "$DOCKER_COMPOSE_COMMAND" &> /dev/null && ! "$DOCKER_COMMAND" compose version &> /dev/null; then
  echo "Error: Neither docker-compose nor docker compose (Docker Compose V2) is installed."
  show_installation_instructions
  exit 1
fi

# Determine which command to use
if command -v "$DOCKER_COMPOSE_COMMAND" &> /dev/null; then
  DOCKER_COMPOSE_COMMAND="$DOCKER_COMPOSE_COMMAND"
elif "$DOCKER_COMMAND" compose version &> /dev/null; then
  DOCKER_COMPOSE_COMMAND="$DOCKER_COMMAND compose"
fi

pull_latest_images() {
  echo "Pulling latest images for project '$PROJECT_NAME' using compose file '$COMPOSE_FILE'..."
  # Check if the compose file exists
  if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo "Error: Docker Compose file '$COMPOSE_FILE' not found."
    exit 1
  fi

  # Pull the latest images
  if ! "$DOCKER_COMPOSE_COMMAND" -f "$COMPOSE_FILE" -p "$PROJECT_NAME" pull; then
    echo "Error: Failed to pull latest images."
    exit 1
  fi
  echo "Successfully pulled latest images."
}

restart_containers() {
  echo "Restarting containers for project '$PROJECT_NAME' using compose file '$COMPOSE_FILE'..."
  # Check if the compose file exists
  if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo "Error: Docker Compose file '$COMPOSE_FILE' not found."
    exit 1
  fi

  # Check if there are running containers
  RUNNING_CONTAINERS=$("$DOCKER_COMPOSE_COMMAND" -f "$COMPOSE_FILE" -p "$PROJECT_NAME" ps -q 2>/dev/null)
  if [[ -n "$RUNNING_CONTAINERS" ]]; then
    echo "Running containers found. Restarting..."
    if ! "$DOCKER_COMPOSE_COMMAND" -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d --remove-orphans; then
      echo "Error: Failed to restart containers."
      exit 1
    fi
  else
    echo "No running containers found. Starting services..."
    if ! "$DOCKER_COMPOSE_COMMAND" -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d; then
      echo "Error: Failed to start services."
      exit 1
    fi
  fi
  echo "Successfully restarted containers."
}

usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -p <project_name>  Specify the Docker Compose project name (default: $(basename "$(pwd)"))"
  echo "  -f <compose_file>  Specify the path to the docker-compose.yml file (default: docker-compose.yml)"
  echo "  -h                 Display this help message"
}

# Parse command-line arguments
while getopts ":p:f:h" opt; do
  case $opt in
  p)
    PROJECT_NAME="$OPTARG"
    ;;
  f)
    COMPOSE_FILE="$OPTARG"
    ;;
  h)
    usage
    exit 0
    ;;
  \:)
    echo "Error: Option -$OPTARG requires an argument." >&2
    usage
    exit 1
    ;;
  ?)
    echo "Error: Invalid option: -$OPTARG" >&2
    usage
    exit 1
    ;;
  esac
done

# Shift off the options to get to any remaining arguments
shift $((OPTIND - 1))

# Check if there are any extraneous arguments
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

# Execute the main logic
pull_latest_images
restart_containers

echo "Docker Compose services updated and restarted."