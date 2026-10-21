#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/compose.yaml"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "[ERROR] Compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] Docker is not installed." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "[ERROR] Docker is not running or permission is insufficient." >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "[ERROR] Docker Compose plugin is unavailable." >&2
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
  update)
    docker compose -f "$COMPOSE_FILE" pull
    docker compose -f "$COMPOSE_FILE" up -d
    ;;
  down)
    docker compose -f "$COMPOSE_FILE" down
    ;;
  test)
    curl --fail --silent --show-error http://127.0.0.1:8080/
    echo
    ;;
  help|-h|--help)
    echo "Usage: bash manage.sh {start|stop|restart|status|logs|update|down|test}"
    ;;
  *)
    echo "[ERROR] Unknown command: $1" >&2
    echo "Usage: bash manage.sh {start|stop|restart|status|logs|update|down|test}" >&2
    exit 1
    ;;
esac
