#!/bin/bash

# Vérifie qu'un argument est fourni
if [ -z "$1" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USERNAME="$1"
SUDO_FILE="/etc/sudoers.d/$USERNAME"

# Vérifie que l'utilisateur existe
if ! id "$USERNAME" &>/dev/null; then
  echo "Erreur: l'utilisateur '$USERNAME' n'existe pas"
  exit 1
fi

# Ajoute la règle sudo
echo "$USERNAME ALL=(root) NOPASSWD: /bin/bash" > "$SUDO_FILE"

# Sécurise les permissions (obligatoire pour sudoers.d)
chmod 440 "$SUDO_FILE"

echo "Accès sudo sans mot de passe accordé à $USERNAME pour /bin/bash"