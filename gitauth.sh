#!/bin/bash

# Vérifie si l'agent SSH tourne
if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
    echo "Aucun agent SSH détecté. Démarrage de l'agent..."
    eval "$(ssh-agent -s)"
else
    echo "Agent SSH déjà actif."
fi

# Vérifie si la clé est chargée
if ! ssh-add -l >/dev/null 2>&1; then
    echo "Aucune clé active. Ajout de la clé ~/.ssh/id_github..."
    ssh-add --apple-use-keychain ~/.ssh/id_github
else
    echo "Clés déjà chargées :"
    ssh-add -l
fi

