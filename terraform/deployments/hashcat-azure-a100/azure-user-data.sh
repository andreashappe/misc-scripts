#! /bin/bash

# update system
sudo apt-get update -y
sudo apt-get upgrade -y

# install hashcat
sudo apt install -y p7zip-full
cd /opt
sudo mkdir /opt/hashcat
cd /opt/hashcat
sudo wget https://hashcat.net/files/hashcat-6.2.6.7z
sudo 7z x hashcat-6.2.6.7z

# install nvidia drivers
sudo wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb 
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-drivers cuda-toolkit
sudo /sbin/reboot
