# UNIVERSITY OF EASTERN PANGASINAN
## College of Information Technology
### CCM101 – Cloud Computing

# ENTERPRISE CLOUD ARCHITECT
## OPERATIONAL MANUAL

**Project:** Secure Multi-Tier Web Application (WordPress + MySQL)

**Prepared by:**
- Christian Jay D. Udtojan
- John Benedict E. Murillo
- Hilario Cedric Catalan
- Mike Arron Gabudao

**Section:** BSIT 4G  
**Instructor:** Jenkielyn C. Torres  
**Date:** October 2026

---

# 1. Project Overview

This operational manual explains how to run a WordPress website and a MySQL database using Docker containers on an Ubuntu Server virtual machine. Oracle VirtualBox is used to run the virtual machine, while Docker Compose starts and manages the services. When the port and network settings are correct, the website can be opened from the Windows computer by visiting `http://localhost:8080`.

# 2. System Architecture

```text
Windows Host / Web Browser
           |
       VirtualBox
           |
 Ubuntu Server 24.04 LTS
           |
 Docker Engine + Compose
           |
     +-----+-----+
     |           |
 WordPress    MySQL 8.0
 (Port 80)   (Port 3306)
     |           |
     +-----------+
           |
    Docker Network
           |
    Persistent Volume
           |
     Database Storage
```

# 3. Demonstration Procedure

## 3.1 Start Ubuntu Server

On your Windows computer, follow these steps:

1. Open Oracle VirtualBox.
2. Select the existing Ubuntu Server virtual machine.
3. Click **Start**.
4. Log in using the Ubuntu username and password created during installation.
5. Wait for the terminal prompt.

If your existing virtual machine is working, you do not need to create another one or install Ubuntu again.

## 3.2 Check Ubuntu, Docker, and Docker Compose

Enter the commands below one at a time:

```bash
lsb_release -a
```

```bash
hostname -I
```

```bash
docker --version
```

```bash
docker compose version
```

```bash
sudo systemctl status docker
```

If the Docker status says `active (running)`, press `q` to leave the status screen.

If Docker is stopped, start it with this command:

```bash
sudo systemctl start docker
```

After starting Docker, check its status again to make sure it is running.

## 3.3 Locate the Project Folder

Make sure the terminal is inside the folder that contains `docker-compose.yml`. In this demonstration, the example folder is:

```bash
cd /home/pogi/ccmfinal
```

```bash
pwd
```

```bash
ls -la
```

Check that `docker-compose.yml` appears in the list.

If you cannot find the folder, search for the file first instead of making a new project folder:

```bash
find /home/pogi -name "docker-compose.yml" 2>/dev/null
```

If the search shows a different path, move to that folder. For example:

```bash
cd /home/pogi/wordpress-stack
```

Use the folder path that actually exists on your virtual machine.

## 3.4 Validate the Docker Compose Configuration

Run:

```bash
docker compose config
```

Check the configuration for the WordPress and MySQL services, database connection details, Docker network, port 8080 mapping, and persistent database volume.

If Docker Compose says it cannot find a configuration file, check that you are in the correct folder and that the file name is correct.

## 3.5 Start WordPress and MySQL

From the project folder, run this command to start the services:

```bash
docker compose up -d
```

Use these commands to check the Compose services and running containers:

```bash
docker compose ps
```

```bash
docker ps
```

If a service is still starting, wait a little and check again. Use the service names shown in your command output.

## 3.6 Open the WordPress Website

On the Windows computer, open Chrome or another browser and go to:

**http://localhost:8080**

If the website does not open, check the VirtualBox port-forwarding rule, Docker port mapping, and container status.

If this is the first time running WordPress, complete its setup. If it has already been set up, the website or login page should appear.

The Ubuntu account, MySQL login, and WordPress administrator account are separate. Use the correct username and password for each one.

## 3.7 Publish a Test Post

Once you are in the WordPress dashboard, follow these steps:

1. Open **Posts**.
2. Click **Add New Post**.
3. Set the title to `Cloud Demo Test`.
4. Add content such as `Testing WordPress and MySQL integration`.
5. Click **Publish**.
6. Open the website and confirm that the post appears.

Complete the first-time WordPress setup before creating the test post. This post will be used later to check whether the data is still saved after restarting the services.

## 3.8 Test Data Persistence

Go back to the Ubuntu terminal and enter these commands:

```bash
docker compose ps
```

```bash
docker compose restart
```

```bash
docker compose ps
```

Open or refresh `http://localhost:8080` in your browser and check that the `Cloud Demo Test` post is still there.

If your instructor requires it, restart the Ubuntu virtual machine too, then check the post again.

If the post is still there after the restart, it shows that the data remained saved during this test.

**Important:** Avoid running `docker compose down -v` during the demonstration because it may delete the project volumes and database data.

## 3.9 Check Logs

If the website will not load or displays an error, check the logs with these commands:

```bash
docker compose logs --tail=50 wordpress
```

```bash
docker compose logs --tail=50 db
```

```bash
docker compose logs -f
```

Press `Ctrl+C` to stop viewing the live logs. This normally does not stop the containers.

If your database service has a different name, use the name shown by `docker compose ps` instead of `db`.

## 3.10 Check the UFW Firewall

If you need to show the firewall settings, check the current UFW status with this command:

```bash
sudo ufw status
```

If UFW is active, make sure only the required ports are allowed.

If the firewall is not set up yet, do not turn it on during the demonstration until you understand the network settings and have protected SSH access.

For the project requirement, the final setup should block incoming connections by default and allow only the application access and remote administration that are needed.

Docker-published ports may bypass some UFW rules, so check which ports can actually be reached. Do not expose MySQL port 3306 to the public internet.

## 3.11 Final Demonstration Checklist

- [ ] Ubuntu Server successfully started in VirtualBox.
- [ ] Ubuntu version and IP address displayed.
- [ ] Docker and Docker Compose versions displayed.
- [ ] Project directory and `docker-compose.yml` confirmed.
- [ ] `docker compose config` executed successfully.
- [ ] WordPress and MySQL containers running.
- [ ] WordPress website opened in the browser.
- [ ] Test post published successfully.
- [ ] Services restarted and saved post verified.
- [ ] Logs checked if needed.
- [ ] UFW status and allowed ports checked, if required.

# 4. Backup Automation and Cron

The CCM101 Mission 10 requirements also include a Bash backup script and a Cron job. The demonstration steps above do not confirm that automatic backups are working, so make sure you set up and test this part before submitting the project.

Create the backup script inside your actual project folder. This example uses `db` as the Compose service name and assumes the database credentials are available inside that container. Check your group's `docker-compose.yml` and adjust the script if needed.

### Backup Script

```bash
#!/bin/bash
set -eu

PROJECT_DIR="/home/pogi/ccmfinal"
BACKUP_DIR="$PROJECT_DIR/backups"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

mkdir -p "$BACKUP_DIR"
cd "$PROJECT_DIR"

docker compose exec -T db sh -c 'exec mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > "$BACKUP_DIR/wordpress_$TIMESTAMP.sql"

test -s "$BACKUP_DIR/wordpress_$TIMESTAMP.sql"

find "$BACKUP_DIR" -type f -name "*.sql" -mtime +7 -delete

echo "Backup completed: $TIMESTAMP"
```

Save the script as `automation-script.sh`.

Then make it executable and run it to test whether it works:

```bash
chmod +x /home/pogi/ccmfinal/automation-script.sh
```

```bash
/home/pogi/ccmfinal/automation-script.sh
```

```bash
ls -lh /home/pogi/ccmfinal/backups
```

Check that the SQL backup file exists and is not empty. Try restoring a backup in a safe test environment, and keep another copy outside the virtual machine.

### Schedule the Backup Using Cron

To run the backup every day at 2:00 AM, open the Cron editor:

```bash
crontab -e
```

Add this schedule:

```cron
0 2 * * * /home/pogi/ccmfinal/automation-script.sh >> /home/pogi/ccmfinal/backup.log 2>&1
```

Save the schedule, then check it using:

```bash
crontab -l
```

The virtual machine, Docker, and MySQL need to be running when the scheduled backup starts.

# 5. Troubleshooting

## Website Does Not Open

Run `docker compose ps` and check the WordPress and database logs. Make sure the browser address, Docker port mapping, VirtualBox forwarding rule, and firewall settings agree with each other.

## Compose File Not Found

Run `pwd` and `ls -la` to check your current folder. Then search for the file using:

```bash
find /home/pogi -name docker-compose.yml 2>/dev/null
```

Move to the folder where the file is located.

## WordPress Cannot Connect to MySQL

Check that the service name, database name, username, and password are the same in the WordPress and MySQL settings.

WordPress should connect to MySQL through the Docker network. If the database service is named `db`, the address is usually `db:3306`.

## Backup Script Fails

Make sure the database container is running, the service name in the script matches the Compose file, the script has permission to run, and the backup folder can be written to.

Review the terminal output and backup log for errors.

# 6. GitHub Repository Requirements

The required files should be saved in the `Laboratory-10-Enterprise-Cloud-Architect` folder inside your existing CCM101 portfolio repository:

```text
Laboratory-10-Enterprise-Cloud-Architect/
├── README.md
├── architecture-diagram.png
├── docker-compose.yml
├── automation-script.sh
├── operational-manual.md
└── final-reflection.md
```

Check that the Compose file and backup script are the ones used in your actual project.

Remove passwords and other private information before uploading files to GitHub. Also include screenshots from your own tests and the exported architecture diagram.

# 7. Maintenance and Security

- Check container status and logs when WordPress is unavailable.
- Keep Ubuntu, Docker, WordPress, and MySQL updated carefully.
- Use strong credentials and never publish them in GitHub.
- Do not publish MySQL port 3306 to the host unless there is a specific, secured reason.
- Verify backup files and periodically test restoring them.
- Keep an extra backup outside the VM.
- Do not run `docker compose down -v` during normal testing because it can remove persistent data.

# 8. Final Reflection

This project helped us learn how to use Ubuntu Server, Docker, Docker Compose, WordPress, and MySQL. We also developed skills in running containers, checking logs, configuring network ports, troubleshooting errors, and creating automated database backups using Bash scripts and Cron. Overall, this activity improved our skills in managing and maintaining cloud-based applications.
