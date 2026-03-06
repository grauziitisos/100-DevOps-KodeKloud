# Nginx + PHP-FPM 8.2 Deployment (Stapp02)

This document describes the steps to install and configure **Nginx** with **PHP-FPM 8.2** on App Server 2 (stapp02).

---

## Steps

### 1. Install required packages
```bash
sudo yum install -y nginx
sudo yum install -y php-fpm php-cli php-mysqlnd
```
####Validate if the installed php version is as per the requirements, if php is installed with the lower version, try enabling Remi and EPEL Repositories.

🔹 Step 1: Enable Remi and EPEL Repositories
sudo dnf install -y epel-release
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm

🔹 Step 2: Reset and Enable PHP 8.1 Stream

First, disable any existing PHP modules:

sudo dnf module reset php -y


Then enable PHP 8.1 stream:

sudo dnf module enable php:remi-8.1 -y

🔹 Step 3: Install PHP 8.1 and PHP-FPM
sudo dnf install -y php php-fpm


You can also install additional PHP modules if needed:

sudo dnf install -y php-mysqlnd php-cli php-common php-opcache php-gd php-curl php-mbstring

🔹 Step 4: Enable and Start PHP-FPM Service
sudo systemctl enable --now php-fpm


Check status:

sudo systemctl status php-fpm

🔹 Step 5: Verify PHP Version
php -v


✅ Expected output:

PHP 8.1.x (cli) (built: ...)

### 2. Configure PHP-FPM
Edit the pool configuration:
```bash
sudo vi /etc/php-fpm.d/www.conf
```

Set the following:
```ini
listen = /var/run/php-fpm/default.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
```

### 3. Configure Nginx
Create config file `/etc/nginx/conf.d/stapp02.conf`:
```nginx
server {
    listen 8099;
    root /var/www/html;
    index index.php index.html;

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php-fpm/default.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

### 4. Enable and start services
```bash
sudo systemctl enable php-fpm --now
sudo systemctl enable nginx --now
```

### 5. Test
```bash
php-fpm -v
# Must show PHP 8.2.x

ls -l /var/run/php-fpm/default.sock
# Must show: nginx nginx

grep "^listen =" /etc/php-fpm.d/www.conf
# Must show: /var/run/php-fpm/default.sock

grep "fastcgi_pass" /etc/nginx/conf.d/stapp02.conf
# Must show: fastcgi_pass unix:/var/run/php-fpm/default.sock;

curl http://stapp02:8099/index.php
# Should return: Welcome to xFusionCorp Industries!
```

---

## Validation Checklist
- [ ] `php-fpm -v` → shows PHP 8.2.x
- [ ] Socket exists at `/var/run/php-fpm/default.sock`
- [ ] Socket owned by `nginx:nginx`
- [ ] `listen = /var/run/php-fpm/default.sock` in `/etc/php-fpm.d/www.conf`
- [ ] `fastcgi_pass unix:/var/run/php-fpm/default.sock;` in nginx config
- [ ] `systemctl status php-fpm` → active (running)
- [ ] `systemctl status nginx` → active (running)
- [ ] `curl http://stapp02:8099/index.php` → shows `Welcome to xFusionCorp Industries!`
