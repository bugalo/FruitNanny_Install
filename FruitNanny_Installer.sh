#!/bin/bash

echo "Update Raspbian and install basic tools."

echo "sudo aptitude update"
sudo aptitude update

echo "sudo aptitude safe-upgrade"
sudo aptitude safe-upgrade

echo "sudo aptitude install vim git libraspberrypi-dev autoconf automake libtool pkg-config alsa-base alsa-tools alsa-utils"
sudo aptitude install vim git libraspberrypi-dev autoconf automake libtool pkg-config alsa-base alsa-tools alsa-utils

echo "Install NodeJS."

echo "curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

echo "sudo apt install -y nodejs"
sudo aptitude install -y nodejs

echo "Enable camera and ssh."

read -n 1 -s -r -p "In the next step, please enable the camera, ssh and resize partition."
echo

echo "sudo raspi-config"
sudo raspi-config

echo "Upgrade Raspberry Pi's firmware."

echo "sudo apt-get install rpi-update"
sudo aptitude install rpi-update

echo "sudo rpi-update"
sudo rpi-update

echo "Disable WiFi Power Saving mode."

echo "sudo iw dev wlan0 set power_save off"
sudo iw dev wlan0 set power_save off

echo "wireless-power off"
echo "" >> /etc/network/interfaces
echo "wireless-power off" >> /etc/network/interfaces

echo "Access through .local domain."

echo "sudo apt-get install avahi-daemon"
sudo apt-get install avahi-daemon

echo "Clone the FruitNanny repository."

echo "cd /opt"
cd /opt

echo "sudo mkdir fruitnanny"
sudo mkdir fruitnanny

echo "sudo chown pi:pi fruitnanny"
sudo chown pi:pi fruitnanny

echo "git clone https://github.com/ivadim/fruitnanny"
git clone https://github.com/ivadim/fruitnanny

echo "Install GStreamer and media plugin."

echo "sudo aptitude install gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-alsa"
sudo aptitude install gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-alsa

echo "Build the GStreamer plugin for the Pi Camera from source."

echo "git clone https://github.com/thaytan/gst-rpicamsrc /tmp/gst-rpicamsrc"
git clone https://github.com/thaytan/gst-rpicamsrc /tmp/gst-rpicamsrc

echo "cd /tmp/gst-rpicamsrc"
cd /tmp/gst-rpicamsrc

echo "./autogen.sh --prefix=/usr --libdir=/usr/lib/arm-linux-gnueabihf/"
./autogen.sh --prefix=/usr --libdir=/usr/lib/arm-linux-gnueabihf/

echo "make"
make

echo "sudo make install"
sudo make install

echo "Install Janus WebRTC Gateway."

echo "sudo aptitude install libmicrohttpd-dev libjansson-dev libnice-dev libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev libopus-dev libogg-dev pkg-config gengetopt libsrtp2-dev"
sudo aptitude install libmicrohttpd-dev libjansson-dev libnice-dev libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev libopus-dev libogg-dev pkg-config gengetopt libsrtp2-dev

echo "git clone https://github.com/meetecho/janus-gateway /tmp/janus-gateway"
git clone https://github.com/meetecho/janus-gateway /tmp/janus-gateway

echo "cd /tmp/janus-gateway"
cd /tmp/janus-gateway

echo "git checkout v0.2.5"
git checkout v0.2.5

echo "sh autogen.sh"
sh autogen.sh

echo "./configure --disable-websockets --disable-data-channels --disable-rabbitmq --disable-mqtt"
./configure --disable-websockets --disable-data-channels --disable-rabbitmq --disable-mqtt

echo "make"
make

echo "sudo make install"
sudo make install

echo "Copy FruitNanny's configuration files to the Janus config directory."

echo "sudo cp /opt/fruitnanny/configuration/janus/janus.cfg /usr/local/etc/janus"
sudo cp /opt/fruitnanny/configuration/janus/janus.cfg /usr/local/etc/janus

echo "sudo cp /opt/fruitnanny/configuration/janus/janus.plugin.streaming.cfg /usr/local/etc/janus"
sudo cp /opt/fruitnanny/configuration/janus/janus.plugin.streaming.cfg /usr/local/etc/janus

echo "sudo cp /opt/fruitnanny/configuration/janus/janus.transport.http.cfg /usr/local/etc/janus"
sudo cp /opt/fruitnanny/configuration/janus/janus.transport.http.cfg /usr/local/etc/janus

echo "Generate the SSL certificates."

echo "cd /usr/local/share/janus/certs"
cd /usr/local/share/janus/certs

echo "sudo openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout mycert.key -out mycert.pem"
sudo openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout mycert.key -out mycert.pem

echo "Enable access to GPIO without root."

echo "sudo adduser $USER gpio"
sudo adduser $USER gpio

echo "Install Adafruit's DHT module."

echo "git clone https://github.com/adafruit/Adafruit_Python_DHT /tmp/Adafruit_Python_DHT"
git clone https://github.com/adafruit/Adafruit_Python_DHT /tmp/Adafruit_Python_DHT

echo "cd /tmp/Adafruit_Python_DHT"
cd /tmp/Adafruit_Python_DHT

echo "sudo apt-get install build-essential python-dev python-pip"
sudo apt-get install build-essential python-dev python-pip

echo "sudo python setup.py install"
sudo python setup.py install

echo "Autostart Audio, Video and Janus."

echo "sudo cp /opt/fruitnanny/configuration/systemd/audio.service /etc/systemd/system/"
sudo cp /opt/fruitnanny/configuration/systemd/audio.service /etc/systemd/system/

echo "sudo cp /opt/fruitnanny/configuration/systemd/video.service /etc/systemd/system/"
sudo cp /opt/fruitnanny/configuration/systemd/video.service /etc/systemd/system/

echo "sudo cp /opt/fruitnanny/configuration/systemd/janus.service /etc/systemd/system/"
sudo cp /opt/fruitnanny/configuration/systemd/janus.service /etc/systemd/system/

echo "sudo systemctl enable audio"
sudo systemctl enable audio

echo "sudo systemctl start audio"
sudo systemctl start audio

echo "sudo systemctl enable video"
sudo systemctl enable video

echo "sudo systemctl start video"
sudo systemctl start video

echo "sudo systemctl enable janus"
sudo systemctl enable janus

echo "sudo systemctl start janus"
sudo systemctl start janus

echo "Install PM2 for automatic nodejs app startup."

echo "sudo npm install pm2 -g"
sudo npm install pm2 -g

echo "pm2 startup"
pm2 startup

echo "sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u pi --hp /home/pi"
sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u pi --hp /home/pi

echo "pm2 save"
pm2 save

echo "Start FruitNanny."

echo "cd /opt/fruitnanny"
cd /opt/fruitnanny

echo "npm install"
npm install

echo "sudo pm2 start server/app.js --name="fruitnanny""
sudo pm2 start server/app.js --name="fruitnanny"

echo "pm2 save"
pm2 save

echo "Install and configure Nginx."

echo "sudo aptitude install nginx"
sudo aptitude install nginx

echo "Remove the default site."

echo "sudo rm -f /etc/nginx/sites-enabled/default"
sudo rm -f /etc/nginx/sites-enabled/default

echo "Copy fruitnanny configurations."

echo "sudo cp /opt/fruitnanny/configuration/nginx/fruitnanny_http /etc/nginx/sites-available/fruitnanny_http"
sudo cp /opt/fruitnanny/configuration/nginx/fruitnanny_http /etc/nginx/sites-available/fruitnanny_http

echo "sudo cp /opt/fruitnanny/configuration/nginx/fruitnanny_https /etc/nginx/sites-available/fruitnanny_https"
sudo cp /opt/fruitnanny/configuration/nginx/fruitnanny_https /etc/nginx/sites-available/fruitnanny_https

echo "Enable new configurations."

echo "sudo ln -s /etc/nginx/sites-available/fruitnanny_http /etc/nginx/sites-enabled/"
sudo ln -s /etc/nginx/sites-available/fruitnanny_http /etc/nginx/sites-enabled/

echo "sudo ln -s /etc/nginx/sites-available/fruitnanny_https /etc/nginx/sites-enabled/"
sudo ln -s /etc/nginx/sites-available/fruitnanny_https /etc/nginx/sites-enabled/

echo "Add new user and password pair."

user_name="user_name"
user_name_2="user_name_2"

while [ $user_name != $user_name_2 ]; do

    read -s -r -p "Input the user name: " user_name
    echo ""

    read -s -r -p "Input the user name again" user_name_2
    echo ""

    if [ $user_name != $user_name_2 ]; then

        echo "The two inputs are not equal. Try again."

    fi

done

echo "sudo sh -c \"echo -n $user_name':' >> /etc/nginx/.htpasswd\""
sudo sh -c "echo -n $user_name':' >> /etc/nginx/.htpasswd"

echo "sudo sh -c \"openssl passwd -apr1 >> /etc/nginx/.htpasswd\""
sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"
