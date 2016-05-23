# Swap
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab

# update and upgrade
apt-get update
apt-get upgrade

# JDK 8
apt-get install -y python-software-properties debconf-utils
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer
apt-get install -y oracle-java8-set-default

# Spark
## TODO

# Mysql
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y mysql-server
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
service mysql restart
mysql -u root -proot < analysis_tool/sql/dbschema.sql;
mysql -u root -proot -e "CREATE USER 'analysis'@'localhost' IDENTIFIED BY 'wjfe3e77l4V';"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON sparkbench.* TO 'analysis'@'localhost' IDENTIFIED BY 'analysis' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# Misc
apt-get install -y git htop iotop iftop

# Python
apt-get install -y python-pip
pip install numpy

# Scala
apt-get install -y scala
