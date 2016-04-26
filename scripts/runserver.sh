# Show what we execute
set -x

# MySQL authentication
MYSQLAUTH="-u $MYSQL_USER -p$MYSQL_PASSWORD -h $MYSQL_HOST"

# Wait for MySQL to come up.
#echo "Waiting for mysql"
#until mysql $MYSQLAUTH -e ""; do
#    echo "Failed to connect to MySQL - retrying..."
#    sleep 1
#done
#echo "Connected..."

mysql $MYSQLAUTH -e "CREATE DATABASE IF NOT EXISTS magento"

cd /var/www/magento2/htdocs

sudo -u mage bin/magento setup:install \
  --admin-firstname=demo \
  --admin-lastname=demo_lastname \
  --admin-email=demo@example.com \
  --admin-user=admin \
  --admin-password=abcd1234 \
  --base-url=http://$PUBLIC_HOST/ \
  --db-host="$MYSQL_HOST" \
  --db-name=magento \
  --db-user="$MYSQL_USER" \
  --db-password="$MYSQL_PASSWORD" \
  --db-prefix=u_

exec /usr/sbin/apache2 -D FOREGROUND
