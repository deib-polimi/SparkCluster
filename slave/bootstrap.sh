# Amenable environment
echo '[ "x$LC_CTYPE" = "xUTF-8" ] && unset LC_CTYPE' >> /home/vagrant/.profile
cat /home/vagrant/.bashrc | awk 'index($0, "#force_color_prompt=yes") { print "force_color_prompt=yes"; next } { print }' > /home/vagrant/.bashrc
chown vagrant:vagrant /home/vagrant/.bashrc

# JDK 8
apt-get install -y python-software-properties debconf-utils
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer
apt-get install -y oracle-java8-set-default

# Spark
wget http://mirrors.muzzy.it/apache/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz
tar xf spark-1.6.1-bin-hadoop2.6.tgz
mv spark-1.6.1-bin-hadoop2.6 /usr/local/spark-1.6.1-bin-hadoop2.6
ln -s /usr/local/spark-1.6.1-bin-hadoop2.6 /usr/local/spark
rm spark-1.6.1-bin-hadoop2.6.tgz

# Ambari
cd /etc/apt/sources.list.d
wget http://public-repo-1.hortonworks.com/ambari/ubuntu14/2.x/updates/2.2.2.0/ambari.list
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
apt-get update
apt-get install -y ambari-agent
apt-get install -y ntp

echo "192.168.17.101 master" >> /etc/hosts
echo "slave1" > /etc/hostname
service hostname restart
