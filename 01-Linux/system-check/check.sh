#!/usr/bin/env bash

# GFY DevOps Toolbox
# Linux Environment Check

set -u

print_title() {
    printf '\n========================================\n'
    printf '      GFY LINUX ENVIRONMENT CHECK\n'
    printf '========================================\n\n'
}

show_item() {
    printf '%-24s %s\n' "$1:" "$2"
}

print_title

# Operating system
if [ -r /etc/os-release ]; then
    . /etc/os-release
    show_item "Operating System" "${PRETTY_NAME:-Unknown}"
else
    show_item "Operating System" "Unknown"
fi

# Kernel and architecture
show_item "Kernel" "$(uname -r)"
show_item "Architecture" "$(uname -m)"

# CPU
if command -v nproc >/dev/null 2>&1; then
    show_item "CPU Cores" "$(nproc)"
else
    show_item "CPU Cores" "Unknown"
fi

# Memory
if [ -r /proc/meminfo ]; then
    total_kb=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
    available_kb=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)

    if [ -n "${total_kb:-}" ] && [ -n "${available_kb:-}" ]; then
        total_gb=$(awk -v n="$total_kb" 'BEGIN {printf "%.2f GB", n/1048576}')
        available_gb=$(awk -v n="$available_kb" 'BEGIN {printf "%.2f GB", n/1048576}')

        show_item "Total Memory" "$total_gb"
        show_item "Available Memory" "$available_gb"
    fi
fi

# Disk
printf '\nDisk Usage:\n'
df -h / 2>/dev/null || true

# User and permissions
printf '\n'
show_item "Current User" "$(id -un)"

if [ "$(id -u)" -eq 0 ]; then
    show_item "Root Privileges" "Yes"
else
    show_item "Root Privileges" "No"
fi

# Docker
printf '\n'

if command -v docker >/dev/null 2>&1; then
    show_item "Docker Installed" "$(docker --version 2>/dev/null || echo 'Version unavailable')"

    if docker info >/dev/null 2>&1; then
        show_item "Docker Engine" "Running"
    else
        show_item "Docker Engine" "Not running or permission denied"
    fi

    if docker compose version >/dev/null 2>&1; then
        show_item "Docker Compose" "$(docker compose version --short 2>/dev/null || echo 'Available')"
    else
        show_item "Docker Compose" "Not available"
    fi
else
    show_item "Docker Installed" "No"
    show_item "Docker Compose" "Not checked"
fi

printf '\nEnvironment check completed.\n\n'