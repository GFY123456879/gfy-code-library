#!/usr/bin/env bash
set -u

REGISTRY="crpi-06dsg9bwdxu9zzat.cn-shanghai.personal.cr.aliyuncs.com"
NAMESPACE="gfy-libary"
REPOSITORY="gfy-libary"

IMAGES=(
  "nginx:stable|nginx-stable"
  "nginx:alpine|nginx-alpine"
  "redis:7-alpine|redis-7-alpine"
  "redis:7|redis-7"
  "mysql:8.0|mysql-8.0"
  "mysql:8.4|mysql-8.4"
  "postgres:16|postgres-16"
  "postgres:17|postgres-17"
  "python:3.12-slim|python-3.12-slim"
  "python:3.13-slim|python-3.13-slim"
  "node:22-alpine|node-22-alpine"
  "node:24-alpine|node-24-alpine"
  "ubuntu:22.04|ubuntu-22.04"
  "ubuntu:24.04|ubuntu-24.04"
  "alpine:3.21|alpine-3.21"
  "alpine:3.22|alpine-3.22"
  "busybox:1.37|busybox-1.37"
  "gitea/gitea:1.23|gitea-1.23"
  "gitea/gitea:1.24|gitea-1.24"
)

OK=0
SKIP=0
FAIL=0
LOG="$PWD/batch-push-results-$(date +%Y%m%d-%H%M%S).txt"

echo "批量镜像同步开始：$(date)"
echo "目标仓库：$REGISTRY/$NAMESPACE/$REPOSITORY"
echo "结果文件：$LOG"

for ITEM in "${IMAGES[@]}"; do
  SOURCE="${ITEM%%|*}"
  TARGET="${ITEM##*|}"
  REMOTE="$REGISTRY/$NAMESPACE/$REPOSITORY:$TARGET"

  echo
  echo "========== $SOURCE -> $TARGET =========="

  # 已存在的远程镜像直接跳过
  if docker manifest inspect "$REMOTE" >/dev/null 2>&1; then
    echo "跳过：远程镜像已存在 $REMOTE" | tee -a "$LOG"
    SKIP=$((SKIP + 1))
    continue
  fi

  # 优先尝试 DaoCloud 代理
  if [[ "$SOURCE" == */* ]]; then
    PULL_IMAGE="docker.m.daocloud.io/$SOURCE"
  else
    PULL_IMAGE="docker.m.daocloud.io/library/$SOURCE"
  fi

  LOCAL=""

  # 本地已有官方源镜像则优先复用，避免重复下载
  if docker image inspect "$SOURCE" >/dev/null 2>&1; then
    LOCAL="$SOURCE"
  elif docker image inspect "$PULL_IMAGE" >/dev/null 2>&1; then
    LOCAL="$PULL_IMAGE"
  else
    for ATTEMPT in 1 2; do
      echo "尝试从代理拉取（第 $ATTEMPT 次）：$PULL_IMAGE"
      if docker pull "$PULL_IMAGE"; then
        LOCAL="$PULL_IMAGE"
        break
      fi
      sleep 2
    done
  fi

  # 代理失败后尝试官方源
  if [[ -z "$LOCAL" ]]; then
    echo "代理未成功，尝试官方源：$SOURCE"
    if docker pull "$SOURCE"; then
      LOCAL="$SOURCE"
    fi
  fi

  if [[ -z "$LOCAL" ]]; then
    echo "失败：无法拉取 $SOURCE" | tee -a "$LOG"
    FAIL=$((FAIL + 1))
    continue
  fi

  if ! docker tag "$LOCAL" "$REMOTE"; then
    echo "失败：镜像打标签 $SOURCE" | tee -a "$LOG"
    FAIL=$((FAIL + 1))
    continue
  fi

  if docker push "$REMOTE"; then
    echo "成功：$REMOTE" | tee -a "$LOG"
    OK=$((OK + 1))
  else
    echo "失败：推送 $REMOTE" | tee -a "$LOG"
    FAIL=$((FAIL + 1))
  fi

  docker image rm "$REMOTE" >/dev/null 2>&1 || true

  echo "磁盘空间："
  df -h /
done

echo
echo "========== 批量同步结束 =========="
echo "本次成功：$OK"
echo "已存在跳过：$SKIP"
echo "失败：$FAIL"
echo "详细结果：$LOG"
