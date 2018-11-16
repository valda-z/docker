#!/bin/bash
cat >/etc/motd <<EOL 
  _____                               
  /  _  \ __________ _________   ____  
 /  /_\  \\___   /  |  \_  __ \_/ __ \ 
/    |    \/    /|  |  /|  | \/\  ___/ 
\____|__  /_____ \____/ |__|    \___  
        \/      \/                  \/ 
EOL

cat /etc/motd

sed -i -e "s/#TODOAPIPORT#/${TODOAPIPORT}/" /var/www/js/app.js 
sed -i -e "s/#TODOAPISERVER#/${TODOAPISERVER}/" /var/www/js/app.js 
sed -i -e "s/#TODOAPIPROTOCOL#/${TODOAPIPROTOCOL}/" /var/www/js/app.js 

nginx