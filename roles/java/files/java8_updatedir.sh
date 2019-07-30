#!/bin/bash
#Workaround to Java 8 repository 
#(as seen on https://askubuntu.com/questions/966107/cant-install-oracle-java-8-in-ubuntu-16-04)

cd /var/lib/dpkg/info

sudo sed -i 's|JAVA_VERSION=8u151|JAVA_VERSION=8u161|' oracle-java8-installer.*
sudo sed -i 's|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/|' oracle-java8-installer.*
sudo sed -i 's|SHA256SUM_TGZ="c78200ce409367b296ec39be4427f020e2c585470c4eed01021feada576f027f"|SHA256SUM_TGZ="6dbc56a0e3310b69e91bb64db63a485bd7b6a8083f08e48047276380a0e2021e"|' oracle-java8-installer.*
sudo sed -i 's|J_DIR=jdk1.8.0_151|J_DIR=jdk1.8.0_161|' oracle-java8-installer.*

sudo apt-get update
sudo apt-get install -f