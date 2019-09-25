#! /bin/sh

# Deploy reddit app

git clone -b monolith https://github.com/express42/reddit.git /etc/reddit/
cd /etc/reddit && bundle install
adduser puma --disabled-password --gecos ""

# Starting script

mkdir /usr/local/puma
wget https://gist.githubusercontent.com/razin92/06870f9eb9e448d3bde12b17113e2233/raw/244fbf48a49954c49967ca620d25eda99686bbad/start.sh -O /usr/local/puma/start.sh
chmod +x /usr/local/puma/start.sh

# Service puma

wget https://gist.githubusercontent.com/razin92/06870f9eb9e448d3bde12b17113e2233/raw/244fbf48a49954c49967ca620d25eda99686bbad/puma.service -O /etc/systemd/system/puma.service
systemctl daemon-reload
systemctl start puma
systemctl enable puma
