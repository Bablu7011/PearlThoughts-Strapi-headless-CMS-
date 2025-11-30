#!/bin/bash

#System update
apt update -y
apt upgrade -y

#Install dependencies
apt install -y curl git ufw apt-transport-https build-essential

#Install node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

#Install pm2
npm install -g pm2

#Create strapi directory
mkdir -p /opt/strapi
cd /opt/strapi

#Install strapi (non-interactive, skip questions) 
printf "N\n" | npx create-strapi-app@latest strapi-app --quickstart --skip-cloud --no-run

#Move into project directory
cd /opt/strapi/strapi-app

#Remove any old build folder
rm -rf build

#Build admin ui with extra memory
NODE_OPTIONS="--max-old-space-size=3072" NODE_ENV=production npm run build

#Start strapi in production mode
pm2 start npm --name strapi -- start

#Save pm2 process for restart
pm2 save
pm2 startup systemd
syscmd=$(pm2 startup systemd | grep sudo)
eval $syscmd

#Allow Strapi port
ufw allow 1337/tcp
