#!/bin/bash

# ==============================================================================
# SCRIPT DE DÉCOMMISSIONNEMENT D’APPLICATION DOCKER
# ==============================================================================

set -e

# ---------------------------
# VARIABLES (À ADAPTER)
# ---------------------------
APP_NAME="$1"
COMPOSE_FILE="${2:-docker-compose.yml}"
BACKUP_DIR="/var/backups/docker-decom/${APP_NAME}"
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# ---------------------------
# CHECKS
# ---------------------------
if [ -z "$APP_NAME" ]; then
  echo "❌ Usage: $0 <app_name> [compose_file]"
  exit 1
fi

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "❌ Fichier docker-compose introuvable: $COMPOSE_FILE"
  exit 1
fi

echo "⚠️  ATTENTION: Décommissionnement de l'application: $APP_NAME"
read -p "Confirmer (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "❌ Annulé"
  exit 1
fi

# ---------------------------
# BACKUP
# ---------------------------
echo "📦 Création du backup..."

mkdir -p "$BACKUP_DIR/$DATE"

echo "→ Backup docker-compose"
cp "$COMPOSE_FILE" "$BACKUP_DIR/$DATE/"

if [ -f ".env" ]; then
  echo "→ Backup .env"
  cp ".env" "$BACKUP_DIR/$DATE/"
fi

echo "→ Backup volumes Docker"
VOLUMES=$(docker compose -f "$COMPOSE_FILE" config --volumes)

for VOLUME in $VOLUMES; do
  echo "   ↳ $VOLUME"
  docker run --rm \
    -v ${VOLUME}:/data \
    -v "$BACKUP_DIR/$DATE":/backup \
    alpine \
    sh -c "tar czf /backup/${VOLUME}.tar.gz /data"
done

# ---------------------------
# STOP SERVICES
# ---------------------------
echo "🛑 Arrêt des conteneurs..."
docker compose -f "$COMPOSE_FILE" down

# ---------------------------
# REMOVE CONTAINERS
# ---------------------------
echo "🧹 Suppression des conteneurs restants..."
CONTAINERS=$(docker ps -a --filter "name=${APP_NAME}" --format "{{.ID}}")

if [ ! -z "$CONTAINERS" ]; then
  docker rm -f $CONTAINERS
fi

# ---------------------------
# REMOVE IMAGES
# ---------------------------
echo "🗑️ Suppression des images..."
IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "$APP_NAME" || true)

for IMAGE in $IMAGES; do
  echo "   ↳ $IMAGE"
  docker rmi "$IMAGE" || true
done

# ---------------------------
# REMOVE VOLUMES
# ---------------------------
echo "💣 Suppression des volumes..."
for VOLUME in $VOLUMES; do
  docker volume rm "$VOLUME" || true
done

# ---------------------------
# CLEAN NETWORKS
# ---------------------------
echo "🌐 Nettoyage des réseaux..."
NETWORKS=$(docker network ls --format "{{.Name}}" | grep "$APP_NAME" || true)

for NET in $NETWORKS; do
  docker network rm "$NET" || true
done

# ---------------------------
# FINAL
# ---------------------------
echo "✅ Décommissionnement terminé"
echo "📁 Backup disponible dans: $BACKUP_DIR/$DATE"
