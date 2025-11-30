# Strapi CMS Deployment on AWS EC2 (t3.medium)

![Status](https://img.shields.io/badge/Status-Complete-green)
![AWS](https://img.shields.io/badge/AWS-EC2-orange)
![Strapi](https://img.shields.io/badge/Strapi-v5-purple)
![Node](https://img.shields.io/badge/Node.js-18.x-green)

## 🚀 Project Overview

This project demonstrates the **automated deployment of Strapi Headless CMS** on an **AWS EC2 (t3.medium)** instance. The objective is to provision a production-ready environment where Strapi is installed, built, and served automatically upon instance launch.

**Key Goals:**
* Deploy Strapi in **Production Mode**.
* Automate process management using **PM2**.
* Expose the Admin Panel publicly on port **1337**.
* Ensure service auto-recovery on system reboots.

---

## 🏗️ Architecture

**Flow:** `User` -> `Internet` -> `AWS Security Group (1337)` -> `EC2 (Ubuntu)` -> `PM2` -> `Strapi App`

This setup focuses on core DevOps skills:
1.  **Cloud Infrastructure:** AWS EC2 & Security Groups.
2.  **OS Administration:** Linux (Ubuntu) & Shell Scripting.
3.  **App Deployment:** Node.js runtime & Build processes.
4.  **Automation:** User Data provisioning.

---

## 📦 Features Implemented

* [x] **Automated Provisioning:** Zero-touch installation using `user_data`.
* [x] **Node.js Environment:** Automated setup of Node.js 18 (LTS) & npm.
* [x] **Strapi Core:** Headless CMS initialized successfully.
* [x] **Production Build:** Optimized admin panel build.
* [x] **Process Management:** Application runs in the background via PM2.
* [x] **Resilience:** Auto-restart configured for server reboots.
* [x] **Health Monitoring:** Verified `/up` health endpoint.
* [x] **Public Access:** Admin panel accessible globally.

---

## ⚙️ Deployment Instructions

### 1. Launch EC2 Instance
* **AMI:** Ubuntu Server 22.04 LTS.
* **Instance Type:** `t3.medium` (Required for build memory).
* **Security Group Rules:**
    * `SSH (22)`: Your IP Only.
    * `Custom TCP (1337)`: Anywhere (`0.0.0.0/0`).

### 2. User Data Script
Copy the following script into the **Advanced Details > User Data** section during launch to automate the setup.

```bash
#!/bin/bash

# 1. System Updates & Node.js Installation
curl -fsSL [https://deb.nodesource.com/setup_18.x](https://deb.nodesource.com/setup_18.x) | sudo -E bash -
sudo apt-get install -y nodejs build-essential

# 2. Install PM2 (Process Manager)
sudo npm install -g pm2

# 3. Setup Project Directory
mkdir -p /home/ubuntu/my-strapi-project
cd /home/ubuntu/my-strapi-project

# 4. Install Strapi (Automated)
yes | npx create-strapi-app@latest . --quickstart --no-run

# 5. Build for Production
npm run build

# 6. Start Application
pm2 start npm --name "strapi" -- run start

# 7. Enable Auto-Startup
pm2 startup
pm2 save
3. Verify Deployment
Connect via SSH and run the following commands to check the status:

Bash

# Check if the service is online locally
curl http://localhost:1337

# Check the specific Strapi health endpoint
curl http://localhost:1337/up
📁 Project Structure
The automation script creates the following structure on the server:

Plaintext

/home/ubuntu/my-strapi-project/
├── .tmp/
├── build/             # Production build artifacts
├── config/            # Server configurations
├── database/          # SQLite data file
├── public/            # Public assets
├── src/               # API & Content Types
└── server.js          # Entry point
🩺 Health & Monitoring
Strapi v5 includes a built-in health check endpoint.

URL: http://<public-ip>:1337/up

Expected Response: {"status":200}

Purpose: Used by load balancers or uptime monitors to ensure the CMS is active.

🔐 Security Note
⚠️ Important: This project exposes port 1337 directly to the public internet for demonstration purposes.

For a Real Production Environment:

Use a Reverse Proxy (Nginx/Apache) to forward port 80/443 to 1337.

Implement SSL/TLS (HTTPS) using Certbot.

Restrict port 1337 access to localhost only via the Security Group.

📝 Conclusion
This project successfully demonstrates a "Lightweight Infrastructure-as-Code" approach. By utilizing AWS User Data, we eliminated manual server configuration, resulting in a reproducible and professional-grade deployment environment.

