#!/bin/bash

#Install java-openjdk11, jenkins, epel, start and enable jenkins
yum install git -y;amazon-linux-extras install java-openjdk11 -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum upgrade -y;amazon-linux-extras install epel -y;yum install jenkins -y
systemctl start jenkins.service;systemctl enable jenkins.service


#Install jdk 17 in /opt and install java-17
cd /opt;wget https://download.oracle.com/java/17/archive/jdk-17.0.8_linux-x64_bin.tar.gz
tar -xvf jdk-17.0.8_linux-x64_bin.tar.gz
echo "export JAVA_HOME=/opt/jdk-17.0.8/" >> /root/.bashrc
echo "export PATH="'$PATH'":/opt/jdk-17.0.8/bin" >> /root/.bashrc
yum install java-17* -y

#Install maven 3.8.8
cd /usr/local/src; sudo wget https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz
tar -xf apache-maven-3.8.8-bin.tar.gz; mv apache-maven-3.8.8/ apache-maven/
echo "export MAVEN_HOME=/usr/local/src/apache-maven" >> /root/.bashrc
echo "export PATH="'${MAVEN_HOME}'"/bin:"'${PATH}'"" >> /root/.bashrc

#Install docker
yum install docker -y; systemctl start docker; systemctl enable docker

source /root/.bashrc
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers