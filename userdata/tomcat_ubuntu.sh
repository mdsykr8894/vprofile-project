#!/bin/bash

# Variables
TOMCAT_VERSION=10.0.20
TOMCAT_USER=tomcat
TOMCAT_GROUP=tomcat
TOMCAT_HOME=/usr/local/tomcat

# Update system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install dependencies
echo "Installing Java and other dependencies..."
sudo apt install openjdk-17-jdk git wget -y

# Create tomcat user
echo "Creating Tomcat user..."
sudo useradd -r -m -U -d $TOMCAT_HOME -s /bin/false $TOMCAT_USER

# Download Tomcat
echo "Downloading Tomcat version $TOMCAT_VERSION..."
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Extract and move to desired location
echo "Installing Tomcat..."
sudo mkdir -p $TOMCAT_HOME
sudo tar xzvf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C $TOMCAT_HOME --strip-components=1

# Set permissions
sudo chown -R $TOMCAT_USER:$TOMCAT_GROUP $TOMCAT_HOME
sudo chmod +x $TOMCAT_HOME/bin/*.sh

# Create systemd service file
echo "Creating Tomcat systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat 10 Web Application Container
After=network.target

[Service]
Type=forking

User=$TOMCAT_USER
Group=$TOMCAT_GROUP

Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Environment="CATALINA_PID=$TOMCAT_HOME/temp/tomcat.pid"
Environment="CATALINA_HOME=$TOMCAT_HOME"
Environment="CATALINA_BASE=$TOMCAT_HOME"
ExecStart=$TOMCAT_HOME/bin/startup.sh
ExecStop=$TOMCAT_HOME/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload and start Tomcat
echo "Enabling and starting Tomcat service..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Check status
echo "Checking Tomcat service status..."
sudo systemctl status tomcat --no-pager

cd /tmp/
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip
apt install unzip -y
unzip apache-maven-3.9.9-bin.zip
cp -r apache-maven-3.9.9 /usr/local/maven3.9
export MAVEN_OPTS="-Xmx512m"

git clone -b main https://github.com/mdsykr8894/vprofile-project.git
cd vprofile-project
/usr/local/maven3.9/bin/mvn install
systemctl stop tomcat
sleep 20
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
systemctl start tomcat
sleep 20
#cp /vagrant/application.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/application.properties
systemctl restart tomcat
