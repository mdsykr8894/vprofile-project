#!/bin/bash

TOMCAT_VERSION=10.0.20
TOMCAT_HOME=/usr/local/tomcat
TOMCAT_USER=tomcat
TOMCAT_GROUP=tomcat

sudo apt update
sudo apt install -y openjdk-17-jdk git wget unzip

# Create tomcat user
sudo useradd -r -m -U -d $TOMCAT_HOME -s /bin/false $TOMCAT_USER

# Download and install Tomcat
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
sudo mkdir -p $TOMCAT_HOME
sudo tar xzvf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C $TOMCAT_HOME --strip-components=1
sudo chown -R $TOMCAT_USER:$TOMCAT_GROUP $TOMCAT_HOME
sudo chmod +x $TOMCAT_HOME/bin/*.sh

# Systemd service
cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat Server
After=network.target

[Service]
Type=forking
User=$TOMCAT_USER
Group=$TOMCAT_GROUP
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Environment="CATALINA_PID=$TOMCAT_HOME/temp/tomcat.pid"
Environment="CATALINA_HOME=$TOMCAT_HOME"
ExecStart=$TOMCAT_HOME/bin/startup.sh
ExecStop=$TOMCAT_HOME/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Install Maven and deploy app
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip
unzip apache-maven-3.9.9-bin.zip
sudo mv apache-maven-3.9.9 /usr/local/maven
export PATH=$PATH:/usr/local/maven/bin

# Clone and build project
cd /tmp
git clone -b local https://github.com/mdsykr8894/vprofile-project.git
cd vprofile-project
/usr/local/maven/bin/mvn install

# Deploy WAR
sudo systemctl stop tomcat
sudo rm -rf $TOMCAT_HOME/webapps/ROOT*
sudo cp target/vprofile-v2.war $TOMCAT_HOME/webapps/ROOT.war
sudo systemctl start tomcat
