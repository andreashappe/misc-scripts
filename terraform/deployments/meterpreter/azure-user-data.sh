#! /bin/bash

# update system
sudo apt-get update -y
sudo apt-get upgrade -y

# install metasploit
sudo apt install curl postgresql postgresql-contrib -y
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall
sudo ./msfinstall

