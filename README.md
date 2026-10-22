# mondedie/flarum

![logo](https://i.imgur.com/Bjrtbsc.png)

[![](https://github.com/mondediefr/docker-flarum/workflows/build/badge.svg)](https://github.com/mondediefr/docker-flarum/actions)
[![](https://img.shields.io/docker/pulls/mondedie/flarum)](https://hub.docker.com/r/mondedie/flarum)
[![](https://img.shields.io/docker/stars/mondedie/flarum)](https://hub.docker.com/r/mondedie/flarum)

### Tag available

 - **latest** [(Dockerfile)](https://github.com/mondediefr/docker-flarum/blob/master/Dockerfile)
 - **stable** [(Dockerfile)](https://github.com/mondediefr/docker-flarum/blob/master/Dockerfile)
 - **1.0.2** [(Dockerfile)](https://github.com/mondediefr/docker-flarum/blob/1.0.2/Dockerfile)
 - **1.2.0** [(Dockerfile)](https://github.com/mondediefr/docker-flarum/blob/1.2.0/Dockerfile)

### Features

- Multi-platform image: `linux/386`, `linux/amd64`, `linux/arm/v6`, `linux/arm/v7`, `linux/arm64`
- Lightweight & secure image
- Based on Alpine Linux 3.24
- **nginx** and **PHP 8.3** (8.3.36 or newer security patch)
- [Flarum Framework](https://github.com/flarum/framework) 1.8.20 (stays on Flarum 1.x)
- MySQL/Mariadb driver
- OPCache extension configured

### Build-time variables

- **VERSION** = Version of [flarum/flarum](https://github.com/flarum/flarum) skeleton (default: *v1.8.19*)
- **CORE_VERSION** = Exact Flarum core version (default: *1.8.20*)
- **COMPOSER_VERSION** = Composer version (default: *2.10.3*)
- **COMPOSER_SHA256** = SHA-256 of the selected Composer PHAR; update it together with **COMPOSER_VERSION**

### Ports

- Default: **8888** (configurable)

### Volume

- **/flarum/app/extensions** : Flarum extension directory
- **/flarum/app/public/assets** : Flarum assets directory
- **/flarum/app/storage/logs** : Flarum logs directory
- **/etc/nginx/flarum** : Nginx location directory

### Environment variables

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **UID** | Flarum user id | *optional* | 991
| **GID** | Flarum group id | *optional* | 991
| **DEBUG** | Flarum debug mode | *optional* | false
| **FORUM_URL** | Forum URL | **required** | none
| **DB_HOST** | MariaDB instance ip/hostname | *optional* | mariadb
| **DB_USER** | MariaDB database username | *optional* | flarum
| **DB_NAME** | MariaDB database name | *optional* | flarum
| **DB_PASS** | MariaDB database password | **required** | none
| **DB_PREF** | Flarum tables prefix | *optional* | none
| **DB_PORT** | MariaDB database port | *optional* | 3306
| **FLARUM_PORT** | Port to run Flarum on inside the container | *optional* | 8888
| **UPLOAD_MAX_SIZE** | The maximum size of an uploaded file | *optional* | 50M
| **PHP_MEMORY_LIMIT** | PHP memory limit | *optional* | 128M |
| **OPCACHE_MEMORY_LIMIT** | OPcache memory size in megabytes | *optional* | 128
| **LOG_TO_STDOUT** | Enable nginx and php error logs to stdout | *optional* | false
| **GITHUB_TOKEN_AUTH** | Github token to download private extensions | *optional* | false
| **PHP_EXTENSIONS** | Install additional php extensions | *optional* | none

### Required environment variable for first installation

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **FLARUM_ADMIN_USER** | Name of your user admin | **required** | none
| **FLARUM_ADMIN_PASS** | User admin password | **required** | none
| **FLARUM_ADMIN_MAIL** | User admin adress mail | **required** | none
| **FLARUM_TITLE** | Set a name of your flarum | *optional* | Docker-Flarum

## Installation

#### 1 - Build the updated image

From this checkout:

```bash
docker build --pull -t docker-flarum:1.8.20 .
```

The examples below use this local image. The historical `mondedie/flarum` tags above are upstream images; building this checkout does not update them.

#### 2 - Docker-compose.yml

```yml
version: "3"

services:
  flarum:
    image: docker-flarum:1.8.20
    container_name: flarum
    env_file:
      - /mnt/docker/flarum/flarum.env
    volumes:
      - /mnt/docker/flarum/assets:/flarum/app/public/assets
      - /mnt/docker/flarum/extensions:/flarum/app/extensions
      - /mnt/docker/flarum/storage/logs:/flarum/app/storage/logs
      - /mnt/docker/flarum/nginx:/etc/nginx/flarum
    ports:
      - 80:8888
    depends_on:
      - mariadb

  mariadb:
    image: mariadb:11.8
    container_name: mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=xxxxxxxxxx
      - MYSQL_DATABASE=flarum
      - MYSQL_USER=flarum
      - MYSQL_PASSWORD=xxxxxxxxxx
    volumes:
      - /mnt/docker/mysql/db:/var/lib/mysql
```

#### 3 - Run it

You need a reverse proxy to access flarum, this is not described here. You can use the solution of your choice (Traefik, Nginx, Apache, Haproxy, Caddy, H2O...etc).

Create a environment file (see docker-compose: /mnt/docker/flarum/flarum.env [here](https://github.com/mondediefr/docker-flarum/tree/master#2---docker-composeyml))

```
# vi /mnt/docker/flarum/flarum.env

DEBUG=false
FORUM_URL=http://domain.tld

# Database configuration
DB_HOST=mariadb
DB_NAME=flarum
DB_USER=flarum
DB_PASS=xxxxxxxxxx
DB_PREF=flarum_
DB_PORT=3306

# User admin flarum (environment variable for first installation)
# /!\ admin password must contain at least 8 characters /!\
FLARUM_ADMIN_USER=admin
FLARUM_ADMIN_PASS=xxxxxxxxxx
FLARUM_ADMIN_MAIL=admin@domain.tld
FLARUM_TITLE=Test flarum
```

Run your docker-compose

```sh
docker compose up -d mariadb
# Wait a moment for the creation of the database
docker compose up -d flarum
```

* :warning: Your admin password must contain at least **8 characters** (FLARUM_ADMIN_PASS).
* If you get an error 500 with _Something went wrong_ message, switch the `DEBUG` environment variable to `true` to see the actual error message in your browser.

![flarum-home](http://i.imgur.com/6kH9iTV.png)

### Install additional php extensions

```yml
version: "3"

services:
  flarum:
    image: docker-flarum:1.8.20
    container_name: flarum
    environment:
      - PHP_EXTENSIONS=bcmath
    volumes:
      - /mnt/docker/flarum/assets:/flarum/app/public/assets
      - /mnt/docker/flarum/extensions:/flarum/app/extensions
      - /mnt/docker/flarum/storage/logs:/flarum/app/storage/logs
      - /mnt/docker/flarum/nginx:/etc/nginx/flarum
```

This example installs php83-bcmath with apk.

You can find a php extension here https://pkgs.alpinelinux.org/packages?name=php83-*&branch=v3.24&arch=x86_64

### Install custom extensions

**Flarum extensions list :** https://flagrow.io/extensions

#### Install an extension

```sh
docker exec -ti flarum extension require some/extension
```

#### Remove an extension

```sh
docker exec -ti flarum extension remove some/extension
```

#### List all extensions

```sh
docker exec -ti flarum extension list
```

### Custom vhost flarum nginx

File to change the vhost flarum `/etc/nginx/flarum/custom-vhost-flarum.conf`  
To use file custom-vhost-flarum.conf add volume `/etc/nginx/flarum`
Create file in `/mnt/docker/flarum/nginx/custom-vhost-flarum.conf`

```nginx
# Example of custom vhost flarum for nginx
# fix nginx issue for fof/sitemap (https://github.com/FriendsOfFlarum/sitemap)

location = /sitemap.xml {
  try_files $uri $uri/ /index.php?$query_string;
}
```

### Custom composer repositories

To use the composer repository system, add your repo name and json representation in `/mnt/docker/flarum/extensions/composer.repositories.txt`:

```
my_private_repo|{"type":"path","url":"extensions/*/"}
my_public_repo|{"type":"vcs","url":"https://github.com/my/repo"}
```

Example for a private repository in github

Add this in `/mnt/docker/flarum/extensions/composer.repositories.txt`
```
username|{"type":"vcs","url":"https://github.com/username/my-private-repo"}
```

Create a token in github with full control of privates repository  
https://github.com/settings/tokens

Add your github token in var environment
```
GITHUB_TOKEN_AUTH=XXXXXXXXXXXXXXX
```

Add your repo in the list file `/mnt/docker/flarum/extensions/list`
```
username/my-private-repo:0.1.0
```

https://getcomposer.org/doc/03-cli.md#modifying-repositories

### Guide for upgrade your flarum container

See [UPGRADE.md](UPGRADE.md). The MariaDB 11.8 example is for new installations; upgrade an existing database separately using the [MariaDB upgrade documentation](https://mariadb.com/docs/server/server-management/install-and-upgrade-mariadb/upgrading).

### Flarum 1.x dependency advisory

Flarum 1.x requires `league/flysystem` 1.x, which has no official patched release for
[GHSA-cxf4-7mrp-vvpr](https://github.com/advisories/GHSA-cxf4-7mrp-vvpr).
This image backports the [upstream fix](https://github.com/thephpleague/flysystem/commit/ef4a9a557d769b5d472c403125716706a0d9cc77)
to reject malformed UTF-8 paths. The build runs regression checks for invalid paths,
normal filenames and path traversal. Composer hooks reapply the patch after install,
update and autoload generation (including normal `reinstall` operations). Startup
also checks/applies the patch before launching the forum.

Do not disable Composer scripts/autoload generation when changing dependencies.
If you must bypass these hooks, run `php /usr/local/lib/flarum/patch-flysystem.php`
before serving requests again. An unexpected dependency source causes patching to
fail, and the extension helper/startup extension restore propagates that failure.

The upstream package version is unchanged, so `composer audit` still reports the
advisory. The narrowly scoped dependency-resolution exception remains; it does not
hide the advisory or disable checks for other vulnerable packages.

## License

Docker image [mondedie/flarum](https://hub.docker.com/r/mondedie/flarum) is released under [MIT License](https://github.com/mondediefr/docker-flarum/blob/master/LICENSE).
