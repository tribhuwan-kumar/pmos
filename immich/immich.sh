#!/bin/sh

stop=false
start=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    -s|--start)
      start=true
      shift
      ;;
    -k|--stop)
      stop=true
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      QUERY="$QUERY $1"
      shift
      ;;
  esac
done

if [ "$stop" = true ]; then
  podman ps -a | grep 'immich' | awk '{print $1}' | xargs podman rm -f
  podman pod rm -f immich-pod
  exit 0
elif [ "$start" = true ]; then
  echo "Creating Immich Pod..."
  podman pod create --name immich-pod --cpus 4 -p 9040:2283 --replace
  # redis
  echo "Starting Redis..."
  podman run -d --pod immich-pod \
    --name immich_redis \
    --replace \
    --restart unless-stopped \
    docker.io/valkey/valkey:8@sha256:81db6d39e1bba3b3ff32bd3a1b19a6d69690f94a3954ec131277b9a26b95b3aa \

  # database
  echo "Starting Database..."
  podman run -d --pod immich-pod \
    --name immich_postgres \
    --replace \
    --oom-score-adj=-500 \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_DB=immich \
    -e POSTGRES_PASSWORD=okaytrytheimmich \
    -e POSTGRES_INITDB_ARGS='--data-checksums' \
    -e PG_SHARED_BUFFERS=64MB \
    -e PG_WORK_MEM=2MB \
    -e PG_MAINTENANCE_WORK_MEM=32MB \
    -v /home/trash/immich/immich_db:/var/lib/postgresql/data \
    --shm-size 128mb \
    --restart unless-stopped \
    ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23
  echo "Waiting 5s for database to initialize..."
  sleep 5

  # ml
  podman run -d --pod immich-pod \
    --name immich_ml \
    --oom-score-adj=-500 \
    --memory=1024m \
    --memory-swap=1g \
    --replace \
    -e MACHINE_LEARNING_WORKERS=1 \
    -e MACHINE_LEARNING_CACHE_SIZE=256 \
    -e MACHINE_LEARNING_PRELOAD=false \
    -v /home/trash/immich/ml_cache:/cache \
    --restart unless-stopped \
    ghcr.io/immich-app/immich-machine-learning:release
  echo "Waiting 5s for ml initialization..."
  sleep 5

  # server
  echo "Starting Server..."
  podman run -d --pod immich-pod \
    --name immich_server \
    --replace \
    --memory=1536m \
    --memory-swap=2g \
    --oom-score-adj=-500 \
    -e TZ=Etc/UTC \
    -e JOBS_WORKERS=1 \
    -e DB_HOSTNAME=127.0.0.1 \
    -e REDIS_HOSTNAME=127.0.0.1 \
    -e DISABLE_VIDEO_TRANSCODING=true \
    -e DISABLE_HEIC=true \
    -e IMMICH_DB_HOSTNAME=127.0.0.1 \
    -e IMMICH_REDIS_HOSTNAME=127.0.0.1 \
    -e NODE_OPTIONS=--max-old-space-size=512 \
    -e DISABLE_VIDEO_TRANSCODING=true \
    -v /home/trash/qwerty/immich:/data \
    -v /home/trash/qwerty/camera:/home/trash/camera \
    -v /etc/localtime:/etc/localtime:ro \
    --restart unless-stopped \
    ghcr.io/immich-app/immich-server:release
fi
