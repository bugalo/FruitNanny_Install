#!/bin/bash -v

## Update Raspbian.
sudo aptitude update
sudo aptitude safe-upgrade

## Install basic tools, dependencies and all the packages needed from Raspbian repositories.
sudo aptitude install vim git libraspberrypi-dev autoconf automake libtool pkg-config alsa-base alsa-tools alsa-utils rpi-update avahi-daemon gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-alsa libmicrohttpd-dev libjansson-dev libnice-dev libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev libopus-dev libogg-dev pkg-config gengetopt libsrtp2-dev build-essential python-dev python-pip nginx

## Install NodeJS.
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo aptitude install -y nodejs

## Configure the Raspberry Pi:
##     1.- Update the raspi-config tool.
##     2.- Change the default user password.
##     3.- Change the Wi-Fi country.
##     4.- Configure to directly boot with the "pi" user.
##     5.- Enable the camera interface.
##     6.- Enable the ssh server.
##     7.- Expand filesystem.
read -n 1 -s -r -p "In the next step, please configure your Raspberry Pi as stated above."
echo
sudo raspi-config

## Upgrade Raspberry Pi's firmware.
sudo rpi-update

## Disable WiFi Power Saving mode.
sudo iw dev wlan0 set power_save off

echo "" >> /etc/network/interfaces
echo "wireless-power off" >> /etc/network/interfaces

## Clone the FruitNanny repository.
cd /opt
sudo mkdir fruitnanny
sudo chown pi:pi fruitnanny
git clone https://github.com/ivadim/fruitnanny

## Install GStreamer and media plugin.
## Build the GStreamer plugin for the Pi Camera from source.
git clone https://github.com/thaytan/gst-rpicamsrc /tmp/gst-rpicamsrc
cd /tmp/gst-rpicamsrc
./autogen.sh --prefix=/usr --libdir=/usr/lib/arm-linux-gnueabihf/
make
sudo make install

## Install Janus WebRTC Gateway.
git clone https://github.com/meetecho/janus-gateway /tmp/janus-gateway
cd /tmp/janus-gateway
git checkout v0.2.5
sh autogen.sh
./configure --disable-websockets --disable-data-channels --disable-rabbitmq --disable-mqtt
make
sudo make install

## Copy FruitNanny's configuration files to the Janus config directory.
sudo cp /opt/fruitnanny/configuration/janus/janus.cfg /usr/local/etc/janus
sudo cp /opt/fruitnanny/configuration/janus/janus.plugin.streaming.cfg /usr/local/etc/janus
sudo cp /opt/fruitnanny/configuration/janus/janus.transport.http.cfg /usr/local/etc/janus

## Generate the SSL certificates.
cd /usr/local/share/janus/certs
sudo openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout mycert.key -out mycert.pem

## Enable access to GPIO without root.
sudo adduser $USER gpio

## Install Adafruit's DHT module.
git clone https://github.com/adafruit/Adafruit_Python_DHT /tmp/Adafruit_Python_DHT
cd /tmp/Adafruit_Python_DHT
sudo python setup.py install

## Autostart Audio, Video and Janus.
sudo cp /opt/fruitnanny/configuration/systemd/audio.service /etc/systemd/system/
sudo cp /opt/fruitnanny/configuration/systemd/video.service /etc/systemd/system/
sudo cp /opt/fruitnanny/configuration/systemd/janus.service /etc/systemd/system/

sudo systemctl enable audio
sudo systemctl start audio
sudo systemctl enable video
sudo systemctl start video

sudo systemctl enable janus
sudo systemctl start janus

## Install PM2 for automatic nodejs app startup.
sudo npm install pm2 -g
sudo pm2 startup

# sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u pi --hp /home/pi
pm2 save

## Start FruitNanny.
cd /opt/fruitnanny
npm install
sudo pm2 start server/app.js --name="fruitnanny"
pm2 save

## Configure Nginx.
## Remove the default site.
sudo rm -f /etc/nginx/sites-enabled/default

## Copy fruitnanny configurations.
sudo cp /opt/fruitnanny/configuration/nginx/fruitnanny_http /etc/nginx/sites-available/fruitnanny_http
sudo cp /opt/fruitnanny/configuration/nginx/fruitnanny_https /etc/nginx/sites-available/fruitnanny_https

## Enable new configurations.
sudo ln -s /etc/nginx/sites-available/fruitnanny_http /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/fruitnanny_https /etc/nginx/sites-enabled/

## Add new user and password pair for FruitNanny remote access.
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

sudo sh -c "echo -n $user_name':' >> /etc/nginx/.htpasswd"
sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"
