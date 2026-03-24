#!/bin/bash
set -euo pipefail

VAULT_VERSION="1.21.1"
VAULT_ZIP="vault_${VAULT_VERSION}_linux_amd64.zip"
VAULT_URL="https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}"
VAULT_BIN="/usr/local/bin/vault"
TMP_DIR="/tmp/vault-install"

echo "Installation Vault ${VAULT_VERSION} via ZIP..."

# Vérif architecture
[[ $(uname -m) == "x86_64" ]] || { echo "Erreur: x86_64 requis"; exit 1; }

# Dépendances
command -v wget >/dev/null || sudo apt update && sudo apt install -y wget unzip
command -v unzip >/dev/null || sudo apt install -y unzip

# Répertoire temp
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# Téléchargement (si absent ou corrompu)
if [[ ! -f "$VAULT_ZIP" ]]; then
    echo "Téléchargement..."
    wget -q "$VAULT_URL"
else
    echo "ZIP existant, skip téléchargement"
fi

# Installation
unzip -o "$VAULT_ZIP"  # -o overwrite si existant
sudo mv vault "$VAULT_BIN"
sudo chmod +x "$VAULT_BIN"

# Nettoyage
cd /
rm -rf "$TMP_DIR"

# Vérif
if vault version | grep -q "Vault v${VAULT_VERSION}"; then
    echo "✅ Vault ${VAULT_VERSION} installé !"
    vault version
else
    echo "❌ Échec vérification"
    exit 1
fi

echo "Test: vault server -dev"


vault login -method=userpass \
  username="vagrant" \
  password="vagrant"
  
vault kv get -mount="ansible" "database/postgres"