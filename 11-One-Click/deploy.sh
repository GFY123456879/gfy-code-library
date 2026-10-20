#!/usr/bin/env bash

# GFY DevOps Toolbox
# Unified Service Deployment Entry

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

usage() {
    echo "GFY DevOps Toolbox"
    echo
    echo "Usage:"
    echo "  $0 nginx"
    echo
    echo "Available services:"
    echo "  nginx    Deploy Nginx web server"
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[ERROR] Required command not found: $1" >&2
        exit 1
    fi
}

deploy_nginx() {
    local compose_file="$REPO_ROOT/03-Containers/nginx/compose.yaml"

    if [[ ! -f "$compose_file" ]]; then
        echo "[ERROR] Nginx Compose file not found:"
        echo "        $compose_file"
        exit 1
    fi

    check_command docker

    if ! docker info >/dev/null 2>&1; then
        echo "[ERROR] Docker is not running or current user lacks permission."
        exit 1
    fi

    if ! docker compose version >/dev/null 2>&1; then
        echo "[ERROR] Docker Compose plugin is unavailable."
        exit 1
    fi

    echo "[INFO] Validating Nginx configuration..."

    docker compose \
        -f "$compose_file" \
        config -q

    echo "[INFO] Starting Nginx..."

    docker compose \
        -f "$compose_file" \
        up -d

    echo
    echo "[INFO] Current service status:"
    docker compose \
        -f "$compose_file" \
        ps

    echo
    echo "[INFO] Nginx deployment command completed."
    echo "[INFO] Check access at: http://SERVER_IP:8080"
}

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

case "$1" in
    nginx)
        deploy_nginx
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        echo "[ERROR] Unknown service: $1"
        echo
        usage
        exit 1
        ;;
esac