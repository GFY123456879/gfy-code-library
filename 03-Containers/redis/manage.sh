#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/compose.yaml"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] Docker is not installed." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "[ERROR] Docker is unavailable." >&2
  exit 1
fi

case "${1:-help}" in
  start|up)
    docker compose -f "$COMPOSE_FILE" up -d
    ;;
  stop)
    docker compose -f "$COMPOSE_FILE" stop
    ;;
  restart)
    docker compose -f "$COMPOSE_FILE" restart
    ;;
  status|ps)
    docker compose -f "$COMPOSE_FILE" ps
    ;;
  logs)
    docker compose -f "$COMPOSE_FILE" logs --tail=100
    ;;
  test)
    docker compose -f "$COMPOSE_FILE" exec -T redis redis-cli ping
    ;;
  down)
    docker compose -f "$COMPOSE_FILE" down
    ;;
  help|-h|--help)
    echo "Usage: bash manage.sh {start|stop|restart|status|logs|test|down}"
    ;;
  *)
    echo "[ERROR] Unknown command: $1" >&2
    exit 1
    ;;
esac
