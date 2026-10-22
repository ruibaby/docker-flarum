# Guide for upgrade your flarum container

### Upgrade an existing Flarum 1.x forum to 1.8.20

This image uses Alpine 3.24, nginx 1.30.6 or newer, PHP 8.3.36 or newer, Composer
2.10.3 and Flarum core 1.8.20. Use `ruibaby/flarum:1.8.20-r1`, which includes the
nginx security fixes missing from the earlier `1.8.20` image. The
`flarum/flarum` skeleton version is 1.8.19; its version is independent
of the core version. This upgrade stays on Flarum 1.x.

1. Back up the database and all mounted directories, and save `config.php`,
   `composer.json` and `composer.lock` from the old container. Test with a copy of
   the data first. Check third-party extensions for PHP 8.3 and Flarum 1.8
   compatibility, and disable them in the admin dashboard before upgrading.
   Extensions installed through the `extension` helper are restored from
   `/flarum/app/extensions/list`; ensure this list includes every extra package
   you need, including packages previously installed directly with Composer.
   The new skeleton no longer bundles `flarum/pusher`. If you use its realtime
   notifications, add `flarum/pusher:^1.0` on a separate line in that list before
   replacing the container.
2. Pull the updated image (supports AMD64 and ARM64):

   ```sh
   docker pull ruibaby/flarum:1.8.20-r1
   ```

3. Change only the `flarum` service image in your Compose file to
   `ruibaby/flarum:1.8.20-r1`. Keep the existing environment variables, mounts and
   database image. The MariaDB 11.8 example in README is for new installations;
   do not point a new database major version at an old data directory without
   following its own upgrade procedure.
4. Stop the forum, recreate the application container and inspect startup logs:

   ```sh
   docker compose stop flarum
   docker compose up -d --no-deps flarum
   docker compose logs flarum
   ```

   Keep public traffic disabled until migrations and checks below succeed.
   Startup restores the extra extensions using Composer; resolve any dependency
   errors before proceeding.
5. Run migrations and clear caches as the configured application user (replace
   `991:991` if you changed `UID`/`GID`):

   ```sh
   docker compose exec --user 991:991 flarum php /flarum/app/flarum migrate
   docker compose exec --user 991:991 flarum php /flarum/app/flarum cache:clear
   docker compose exec --user 991:991 flarum php /flarum/app/flarum info
   docker compose exec flarum php --version
   docker compose exec flarum nginx -v
   docker compose exec flarum composer --version
   ```

   Confirm core 1.8.20, PHP 8.3.36 or newer and nginx 1.30.6 or newer, then check
   login, discussions, uploads and the admin dashboard. Re-enable compatible
   extensions and restore public traffic. To roll back after migrations, restore
   the database and mounted directories from the same backup together with the
   previous image.

This image backports the Flysystem path-validation fix while retaining the 1.x API.
See the [dependency advisory note](README.md#flarum-1x-dependency-advisory) for the
Composer hooks and narrowly scoped exception. Because the upstream package version
is unchanged, `composer audit` will continue to report the advisory.

### Upgrade to v1.3.0 from v1.2.0

:warning: Backup your database, config.php, composer.lock and assets folder  
:warning: Disable all 3rd party extensions prior to upgrading in panel admin.

1 - Update your docker-compose file, see an example [here](https://github.com/mondediefr/docker-flarum/tree/master#2---docker-composeyml)

```yml
version: "3"

services:
  flarum:
    image: mondedie/flarum:1.3.0
    ...
```

2 - Pull the last docker images

```sh
docker pull mondedie/flarum:1.3.0
docker-compose stop flarum
docker-compose rm flarum
docker-compose up -d flarum
```

3 - Updating your database and removing old assets & extensions

```sh
docker exec -ti flarum php /flarum/app/flarum migrate
docker exec -ti flarum php /flarum/app/flarum cache:clear
```

After that your upgrade is finish. :tada: :tada:

### Upgrade to v1.2.0 from v1.0.2

:warning: Backup your database, config.php, composer.lock and assets folder  
:warning: Disable all 3rd party extensions prior to upgrading in panel admin.

1 - Update your docker-compose file, see an example [here](https://github.com/mondediefr/docker-flarum/tree/master#2---docker-composeyml)

```yml
version: "3"

services:
  flarum:
    image: mondedie/flarum:1.2.0
    ...
```

2 - Pull the last docker images

```sh
docker pull mondedie/flarum:1.2.0
docker-compose stop flarum
docker-compose rm flarum
docker-compose up -d flarum
```

3 - Updating your database and removing old assets & extensions

```sh
docker exec -ti flarum php /flarum/app/flarum migrate
docker exec -ti flarum php /flarum/app/flarum cache:clear
```

After that your upgrade is finish. :tada: :tada:
