#!/bin/bash

conn_du_jour=$(last | grep "$(LC_TIME=en_US.UTF-8 date +"%a %b %e")")
nombre_conn=`last | grep "$(LC_TIME=en_US.UTF-8 date +"%a %b %e")" | wc -l`
list_user=`last | grep "$(LC_TIME=en_US.UTF-8 date +"%a %b %e")" | awk '{print $1}' | uniq`

last_conn=`last | head -n1 | awk '{print $3,$4,$5,$6}'`
last_conn_date=`last | head -n1 | awk '{print $3,$4,$5}'`
last_tty=`last | head -n1 | awk '{print $2}'`
 
# echo $conn_du_jour
# echo $nombre_conn
# echo $list_user
# echo $last_conn
# echo $last_conn_date
# echo $last_tty

# echo -e "Utilisateur;Nombre de connexions;Dernière connexion;IP / TTY"
# echo -e "$list_user;$nombre_conn;$last_conn;$last_tty"

last | while read -r line; do
  list_user=`$line | grep "$(LC_TIME=en_US.UTF-8 date +"%a %b %e")" | awk '{print $1}' | uniq`
  echo $list_user


#   echo "$line"
done
