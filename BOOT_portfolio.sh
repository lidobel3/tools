#!/bin/bash
set -e  # stoppe le script dès qu'une commande échoue

CONTAINER_NAME="portfolio_ssl"
IMAGE_NAME="lidobel3/portfolio"
BASE_PATH="/home/terraform-user/gutenify-lynx"

# Supprimer un conteneur existant (évite le "Conflict. The container name is already in use")
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "🧹 Suppression de l'ancien conteneur $CONTAINER_NAME..."
    docker rm -f $CONTAINER_NAME
fi

echo "🚀 Démarrage du conteneur $CONTAINER_NAME..."

docker run -d \
  --name=$CONTAINER_NAME \
  -p 80:80 -p 443:443 \
  --mount type=bind,src=$BASE_PATH/ssl/privkey.pem,dst=/etc/nginx/ssl/privkey.pem,readonly \
  --mount type=bind,src=$BASE_PATH/ssl/fullchain.pem,dst=/etc/nginx/ssl/fullchain.pem,readonly \
  --mount type=bind,src=$BASE_PATH,dst=/usr/share/nginx/html/,readonly \
  --mount type=bind,src=$BASE_PATH/nginx.conf,dst=/etc/nginx/nginx.conf,readonly \
  $IMAGE_NAME

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors du lancement du conteneur. Consulte les logs avec :"
    echo "   docker logs $CONTAINER_NAME"
else
    echo "✅ Conteneur $CONTAINER_NAME lancé avec succès !"
    echo "   Vérifie sur https://localhost ou https://<ton_IP>"
fi


# #!/bin/bash

# docker run -d --name=portfolio_ssl -p 443:443 -p 80:80 \
# --mount type=bind,src=/home/terraform-user/gutenify-lynx/ssl/privkey.pem,dst=/etc/nginx/ssl/privkey.pem \
# --mount type=bind,src=/home/terraform-user/gutenify-lynx/ssl/fullchain.pem,dst=/etc/nginx/ssl/fullchain.pem \
# --mount type=bind,src=/home/terraform-user/gutenify-lynx/,dst=/usr/share/nginx/html/ \
# --mount type=bind,src=/home/terraform-user/gutenify-lynx/nginx.conf,dst=/etc/nginx/nginx.conf \
# lidobel3/portfolio

# if [ $? != 0 ];
# then
#     echo "Erreur dans la commande faire un docker logs portfolio_ssl"
# else
#     echo "OK!!"
# fi