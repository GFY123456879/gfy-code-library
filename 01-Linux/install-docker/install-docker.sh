#!/usr/bin/env bash

# GFY DevOps Toolbox
# Docker Engine Installer
# Supported: Ubuntu / Debian

set -Eeuo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Require root privileges
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        exec sudo bash "$0" "$@"
    else
        error "Please run this script as root."
        exit 1
    fi
fi

# Detect Linux distribution
if [ ! -r /etc/os-release ]; then
    error "Cannot detect Linux distribution."
    exit 1
fi

. /etc/os-release

case "${ID:-}" in
    ubuntu)
        REPO_URL="https://download.docker.com/linux/ubuntu"
        ;;
    debian)
        REPO_URL="https://download.docker.com/linux/debian"
        ;;
    *)
        error "Unsupported distribution: ${ID:-unknown}"
        error "This version supports Ubuntu and Debian only."
        exit 1
        ;;
esac

# Detect release codename
CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"

if [ -z "$CODENAME" ]; then
    error "Cannot determine distribution codename."
    exit 1
fi

# Detect CPU architecture
if ! command -v dpkg >/dev/null 2>&1; then
    error "dpkg is not available."
    exit 1
fi

ARCH="$(dpkg --print-architecture)"

info "Operating system: ${PRETTY_NAME:-$ID}"
info "Release codename: $CODENAME"
info "Architecture: $ARCH"

# Avoid modifying an existing Docker installation
if command -v docker >/dev/null 2>&1; then
    warn "Docker is already installed."
    docker --version
    warn "No changes have been made."
    exit 0
fi

echo
warn "This script will modify system packages and repositories."
warn "It will install Docker Engine and the Compose plugin."
warn "Review the script before running it on a production server."
echo

read -r -p "Continue with installation? Type YES: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    info "Installation cancelled."
    exit 0
fi

# Install prerequisites
apt-get update

apt-get install -y ca-certificates curl

# Configure Docker's official signing key
install -m 0755 -d /etc/apt/keyrings

curl -fsSL "${REPO_URL}/gpg" \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

# Configure the official Docker repository
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: ${REPO_URL}
Suites: ${CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Install Docker Engine and Compose
apt-get update

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Enable and start Docker
systemctl enable --now docker

# Verify installation
info "Docker version:"
docker --version

info "Docker Compose version:"
docker compose version

info "Docker service status:"
systemctl is-active docker

info "Installation completed."