#!/bin/bash

COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME=$(basename "$(pwd)")

pull_latest_images() {
  docker-compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" pull
}

restart_containers() {
  RUNNING_CONTAINERS=$(docker-compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" ps -q)
  if [[ -n "$RUNNING_CONTAINERS" ]]; then
    docker-compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d --remove-orphans
  else
    echo "No running containers found. Starting services..."
    docker-compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d
  fi
}

usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -p <project_name>  Specify the Docker Compose project name"
  echo "  -f <compose_file>  Specify the path to the docker-compose.yml file"
  echo "  -h                 Display this help message"
}

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
    echo "Option -$OPTARG requires an argument."
    usage
    exit 1
    ;;
  ?)
    echo "Invalid option: -$OPTARG"
    usage
    exit 1
    ;;
  esac
done

pull_latest_images
restart_containers

echo "Docker Compose services updated and restarted."
