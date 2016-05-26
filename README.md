# LDAP Toolbox - Self-Service-Password

> Originally developed by "LTB-Project"

A PHP-based web-application (running on an Apache Webserver) that allows users to change their password in an LDAP directory. The application is developed by the LTB-Project (see http://ltb-project.org/wiki/documentation/self-service-password).

Configuration is performed automatically during each start-up to link to the appropriate LDAP- and/or Mail-Containers.

**NOTE:** On purpose, there is no secured channel (TLS/SSL) to the OpenLDAP-Server, because its service will never be exposed to the world.

## Requirements

- Docker (>= 1.9.0)
- OpenLDAP-Server (required)
- Mail-Server (optional)

## Provided Resouces

The service provides the following network ports and filesystems.

### Exposed Ports

- `80` : Web-Server (unsecure)

### Exposed Filesystems ###

None

## Usage ##

The created container is configured automatically by the `entrypoint`-script during **each** run.

During this **each** run the following environment variables are evaluated:

OpenLDAP-Server (required):

- `LDAP_BASE` (default: empty)
  - LDAP-Domain to search for user-entries
  - Provide in dotted (`.`) notation (i.e. domain.com)
- `LDAP_HOST` (default: empty)
  - LDAP-Server's hostname or IP-address
- `LDAP_PORT` (default: 389)
  - LDAP-Server's port
- `LDAP_USER` (default: cn=admin,${LDAP_BASE})
  - Complete DN of the admin user, which is allowed to change user passwords.
- `LDAP_PASS`
  - Password of the admin user

Mail-Server (optional):

- `SMTP_HOST` (default: empty)
  - Mail-Server's hostname or IP-address
- `SMTP_PORT` (default: 25)
  - Mail-Server's port
- `SMTP_USER` (default: empty)
  - Username for sender's mail-account
  - If omitted, authentication is disabled
- `SMTP_PASS` (default: empty)
  - Password for sender's mail-account
  - If omitted, authentication is disabled
- `SMTP_FROM` (default: `root(at)$HOSTNAME`)
  - The address from which the password notification is coming from
- `SMTP_TLS` (default: off)
  - Enable TLS connection ("on" OR "off")

> If Mail-Server is not set, Password-Reset will be disabled in Web-Interface!

## Quick Start
You can either run the image and link it to an external configuration file, or you can rebuild your own standalone image.

#### Running from the image, i.e. the `--with-volume` way
Pull the latest version of the image from the docker index. This is the recommended method of installation as it is easier to update image in the future. These builds are performed by the **Docker Trusted Build** service.

```bash
docker pull devsu/ldap-self-service-password:0.9
```

Then, provide your own `config.inc.php` file, downloaded from   http://tools.ltb-project.org/projects/ltb/repository/entry/self-service-password/tags/0.9/conf/config.inc.php and modified according to your settings.

You can now run container:
* in foreground:
```bash
docker run -it --rm -p 8765:80 -v /path/to/config.inc.php:/usr/share/self-service-password/conf/config.inc.php devsu/ldap-self-service-password:0.9
```
* as a daemon:
```bash
docker run -d -p 8765:80 -v /path/to/config.inc.php:/usr/share/self-service-password/conf/config.inc.php devsu/ldap-self-service-password:0.9
```

The examples above expose service on port `8765`, so you can point your browser to http://hostname:8765/ in order to change LDAP passwords.

#### Building the image yourself

```bash
git clone https://github.com/devsu/docker-ldap-self-service-password.git
cd docker-ldap-self-service-password
```
Edit `assets/config.inc.php` according to your local settings, then (re)build image with:
```bash
docker build -t="$USER/ldap-self-service-password" .
```
You can now run container:
* in foreground:
```bash
docker run -it --rm -p 8765:80 $USER/ldap-self-service-password
```
* as a daemon:
```bash
docker run -d -p 8765:80 $USER/ldap-self-service-password
```

## Troubleshooting

#### What's going on ?
You can debug LDAP connection problems by adding this line in  `config.inc.php`:
```php
ldap_set_option(NULL, LDAP_OPT_DEBUG_LEVEL, 7);
```
Then inspect apache logs of a runnning container:
```bash
docker exec -ti $(docker ps | grep 'ldap-self-service-password' | awk '{print $1}') tail /var/log/apache2/error.log
```

#### LDAPS with self-signed certificate
When connecting with LDAPS protocol to a server wtih a self-signed certificate, you will see this error in apache logs:
```
TLS: peer cert untrusted or revoked (0x42)
TLS: can't connect: (unknown error code).
```
Add this into `config.inc.php` to disable all certificate validation:
```php
putenv('LDAPTLS_REQCERT=never');
```
