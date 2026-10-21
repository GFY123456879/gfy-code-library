# GFY DevOps Toolbox

A reusable collection of Linux administration scripts and container deployment templates.

## Requirements

- Ubuntu or Debian Linux
- Git
- Docker Engine
- Docker Compose plugin

## Nginx

Deploy Nginx:

    bash 11-One-Click/deploy.sh nginx

Manage the service:

    bash 03-Containers/nginx/manage.sh status
    bash 03-Containers/nginx/manage.sh logs
    bash 03-Containers/nginx/manage.sh restart
    bash 03-Containers/nginx/manage.sh test
    bash 03-Containers/nginx/manage.sh stop
    bash 03-Containers/nginx/manage.sh start

Default URL:

    http://SERVER_IP:8080

Only expose ports to trusted networks unless firewall rules and access controls are configured.
