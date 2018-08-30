#!/bin/bash

#Apache virtualhost adding script by Markus Torppa
#Version 1.0.0

echo "Add new virtualhost. Please dont use .dev-suffix."
echo "Chrome-based browsers doesn't show local sites using .dev-suffix."
echo "Read more about it here: https://iyware.com/dont-use-dev-for-development/"
echo "And here: https://gist.github.com/lightvision/44662003c07083f208ad"
echo "---------------------------------------"
echo "Type virtualhost name (example: "example.oo"): "
read virtualhost_name
##################VARIABLES##########################

CONFDIR="/etc/apache2/sites-available/"

CONFFILE="$virtualhost_name.conf"

LOCAL_IP="127.0.0.1"

APACHE_LOG_DIR="/var/log/apache2/"

APACHE_HTML_DIR="/var/www/html/"

#####################################################

create_conf() {

  touch $CONFDIR$CONFFILE

}

create_logs() {

  touch "$APACHE_LOG_DIR$virtualhost_name.error.log"

  touch "$APACHE_LOG_DIR$virtualhost_name.access.log"

}

create_html_dir() {

  mkdir -p "$APACHE_HTML_DIR$virtualhost_name"

}

create_index_html() {

  touch "$APACHE_HTML_DIR$virtualhost_name/index.html"

}

index_html_content() {

  echo "<!DOCTYPE html>
<html>
<head>
<title>$virtualhost_name</title>
</head>
<body>

<h1>$virtualhost_name works!</h1>

</body>
</html>
"

}


conf_text() {

  echo "<VirtualHost *:80>
    ServerName $virtualhost_name
    ServerAlias www.$virtualhost_name
    ServerAdmin webmaster@$virtualhost_name
    DocumentRoot $APACHE_HTML_DIR$virtualhost_name
    ErrorLog $APACHE_LOG_DIR$virtualhost_name.error.log
    CustomLog $APACHE_LOG_DIR$virtualhost_name.access.log combined
    LogLevel warn
</VirtualHost>"

}
echo "---------------------------------------"

if [ -z $virtualhost_name ]; then

  echo "You typed empty string."
  echo "---------------------------------------"

  exit 1

fi


#check if virtualhost is already in use
if [ -e $CONFDIR$CONFFILE  ]; then
  #statements
  echo "Site already exist. Try other name."
  echo "---------------------------------------"

  exit 1

fi

$(create_conf)
echo "Conf-file created."
echo "---------------------------------------"

$(create_logs)
echo "Logs created."
echo "---------------------------------------"

/bin/cat <<EOM >$CONFDIR$CONFFILE
$(conf_text)
EOM
echo "Configuration added to conf-file."
echo "---------------------------------------"

$(create_html_dir)
echo "HTML dir created"
echo "---------------------------------------"
$(create_index_html)
echo "index.html created"
echo "---------------------------------------"
/bin/cat <<EOM >/var/www/html/$virtualhost_name/index.html
$(index_html_content)
EOM

echo "$LOCAL_IP       $virtualhost_name" >> /etc/hosts
echo "$LOCAL_IP       www.$virtualhost_name" >> /etc/hosts

echo "Virtualhost added to hosts-file"
echo "---------------------------------------"

if [ -e $CONFDIR$CONFFILE ]; then

  sudo a2ensite $CONFFILE
  echo "---------------------------------------"
  echo "Host conf enabled"
  echo "---------------------------------------"
  echo "Restarting apache..."
  sudo systemctl reload apache2
  sudo systemctl restart apache2
  echo "---------------------------------------"
  echo "Apache restarted"
  echo "---------------------------------------"
  echo "$virtualhost_name is now enabled!"
  #statements
fi
echo "---------------------------------------"
