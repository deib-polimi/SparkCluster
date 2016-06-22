# Swap
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab

# update and upgrade
apt-get update -y
apt-get upgrade -y

# JDK 8
apt-get install -y python-software-properties debconf-utils
add-apt-repository -y ppa:webupd8team/java
apt-get update -y
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer
apt-get install -y oracle-java8-set-default

# Ambari
cd /etc/apt/sources.list.d
wget http://public-repo-1.hortonworks.com/ambari/ubuntu14/2.x/updates/2.2.2.0/ambari.list

# Dirty trick to work around the missing signature key issue
cat > /tmp/hdp.key << 'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQINBE/kz5QBEACz65O0pyfgvYrPxXNBKtMaP5HWX1X6rIReg3K24Awn2ULxvFNb
7/zepCopt7IbEwqfMSRI3DbdhA1kNbQzRBgyKXQajH3k8Ows7VPit6m6Scwfyyaa
dCIBaZWF8jcRsFjHUF4kgK4uZ3gx27bns8HDCpXUKkuZ08n0ggDiZ7Jx5Lnnfk6i
4iHWSXPyS6x0XPVyJYsdXRnONOKN/8KJosMQEzEjPx7/y4S4MycshARkq8g6gK+E
+sHtwfFqJDxYQmh7e77Fr3tLquE86VIVdPjjas2z+sttm+TPlfyoAAGKBhSh6OKX
RRhNXngMJcSMYQ5UIFDzc2rOapTSd+zO7tNJZCD64mbKDSr3Bt9uZ+dtEUEdkp2v
3byuR3E6mEITxEbImtPoVcXCAECqC7SKecT8BTDgt7ZcdOLsnnH5lTadSkYm+aAq
XUEqVBONzxMEGzTzwPy8lHqKuZ1vFgehHRu1lxGpR30cVZLSEXHdIKWB3amt+BlH
7aF/lGpjmxwmFESxFnDpXG4DrxuIOjicnAWD0nBqVActPaSCq0WCSjh11lodOr/2
9lbKCgXlh6Ynb84ZCy5T8Crx+j3h5J3InbUyoFj4gQP/3AHbC3Ig3Oq6udZ8LEHW
jOpA2+eY7FbB9FOvK0jNkmvDJ2f8mVBGaBI4OL+jkKe7Qcn/UwLA8foObwARAQAB
tC1KZW5raW5zIChIRFAgQnVpbGRzKSA8amVua2luQGhvcnRvbndvcmtzLmNvbT6J
AjgEEwECACIFAk/kz5QCGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJELlz
OnoHUTytmekP/0Mlg0VmV033+JzLShpt5uEcIGF1ZCJd2Mwygu1I4JAu/fezntN9
xjPxNvpUTf4OtbrSJKRBZp4awENOXfNz/LCjysBCOP4MoVHS8Vu2oM8pknuNp5aA
lgkYX+z8YFYEdQ3JHtB6ZAt/b0XNQs3BAH71lYHY2yuUbFlB5IHztaEGBYbWuKI2
haI9/31TWEyz4L2Uf/kelHT4vjadJvftQidoRKVFUY21JPgTgwXAtaFOtUNbx2xT
xklPYb8mBqiibNFn3L/hYvlvm+LMhR3LLS3OI5wh5Rr7jWIPY5YBVp0k9OYOiH7i
AWwA786SXa4oqin9IPQUaflpfVNlCjVzJzKRvuFP99R2v1f44IwTJ9QLyYOC46i6
uChEI2rBCI19pKuOH3L9xXxbeEDYDQ7j7eSrl/BrFRYoB8AH2lXmB7IRWRKU3+Ll
FterDA76O7EDPrBKJ9gH6S8sAAE8RiFfNxj4TuYWvzoX9bMe0TLoAZcltAbRuG87
VPzDLVP1lgkBL/BsIywDG423dSZLFm1KF4ptVMGhM+wbEVPsno1AjkOzwmVzVLjZ
5iZJNVf/ruxY0iHhfYnyxz8xCqMQVv9BJ0XOuzk2xU2hFXD9rKg6UCuU/S25X0f4
WdfF0yTKCqONNpTRqL+/hPP61Tql7zZEBSaCaQEfBnC9qMJaZprK0ccz
=I2D5
-----END PGP PUBLIC KEY BLOCK-----
EOF

apt-key add /tmp/hdp.key
rm -f /tmp/hdp.key

apt-get update -y
apt-get install -y ambari-server
apt-get install -y ambari-agent
apt-get install -y ntp

# Hosts
echo "master" > /etc/hostname
service hostname restart

# Misc
apt-get install -y git htop iotop iftop ansible

# Python
apt-get install -y python-dev python-pip
pip install numpy

# Scala
apt-get install -y scala

#clean
apt-get autoremove
apt-get clean