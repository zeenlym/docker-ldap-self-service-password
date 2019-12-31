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

### Exposed Filesystems

None

## Usage

The created container is configured automatically by the `entrypoint`-script during **each** run.

During this **each** run the following environment variables are evaluated:

General Variables:

- `SERVER_HOSTNAME` (default: ${HOSTNAME})
  - Override the default-hostname used in mails and web-interface

LDAP Self-Service-Password (optional):

- `LSSP_ATTR_LOGIN` (default: uid)
  - LDAP attribute for "Login"-Name
- `LSSP_ATTR_FN` (default: cn)
  - LDAP attribute for user's full name
- `LSSP_ATTR_MAIL` (default: mail)
  - LDAP attribute for user's mail address (required for password-reset support)
- `LSSP_DEFAULT_ACTION` (default: change)
  - LSSP default action for changing password (supported are `change`, `sendtoken` or `sendsms`)
- `LSSP_MAIL_FROM_LDAP` (default: false)
  - Don't ask for user's mail address. It will use the first address found in the corresponding user DN.
- `LSSP_SHOW_MENU` (default: true)
  - Show menu on top of the page

OpenLDAP-Server (required):

- `LDAP_BASE` (default: empty)
  - LDAP-Domain to search for user-entries
  - Provide in dotted (`.`) notation (i.e. domain.com)
- `LDAP_HOST` (default: empty)
  - LDAP-Server's hostname or IP-address
- `LDAP_STARTTLS` (default: true)
  - Use STARTTLS for connection to LDAP
- `LDAP_USER` (default: `cn=admin,${LDAP_BASE}`)
  - Complete DN of the admin user, which is allowed to change user passwords.
- `LDAP_PASS`
  - Password of the admin user
- `LDAP_AD_MODE` (default: false)
  - Enable support for Active Directory

Mail-Server (optional):
> If `SMTP_HOST` is not set, Password-Reset via Mail-Tokens will be disabled in the Web-Interface!
> If either `SMTP_USER` or `SMTP_PASS` are empty, SMTP connects without user credentials!

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
- `SMTP_FROM` (default: `root(at)${SERVER_HOSTNAME}`)
  - The address from which the password notification is coming from
- `SMTP_TLS` (default: true)
  - Enable TLS connection

reCAPTCHA (optional):
- `RECAPTCHA_USE` (default: false)
  - Activate reCAPTCHA feature
- `RECAPTCHA_PUB_KEY` (default: empty)
  - reCAPTCHA public key
- `RECAPTCHA_PRV_KEY` (default: empty)
  - reCAPTCHA private key
- `RECAPTCHA_SSL` (default: false)
  - Enable TLS
- `RECAPTCHA_THEME` (default: white)
  - Choose theme

### Link to a supported LDAP-Container

If you have a running OpenLDAP container of the following types

- [dtwardow/openldap](https://hub.docker.com/r/dtwardow/openldap/)
- [dinkel/openldap](https://hub.docker.com/r/dinkel/openldap/)

you can link those containers directly using the link-alias `ldap` which will provide the following environment variables automatically

- `LDAP_HOST` (by Docker Environment)
- `LDAP_PORT` (by Docker Environment)
- `LDAP_USER`
- `LDAP_PASS`
- `LDAP_BASE`

### Link to a supported Mail-Server Container

If you have running Mail-Server inside a container, you can link such a container directly using the link-alias `mail`.
This will provide the following environment variables:

- `SMTP_HOST` (by Docker Environment)
- `SMTP_PORT` (by Docker Environment)

### Advance configuration

If you want to override configuration you can mount volume for `/usr/share/self-service-password/conf/conf.d` and put your conf.php in it.

Password policy

Put this file in local `lssp.d` directory:

> ppolicy.php

```php
<?php
$pwd_min_length = 4;
$pwd_max_length = 24;

$pwd_min_lower = 3;
$pwd_min_upper = 1;
$pwd_min_digit = 1;
$pwd_min_special = 1;

$pwd_special_chars = "^a-zA-Z0-9";
$pwd_complexity = 4;

$pwd_no_reuse = true;

$pwd_show_policy = "always";
?>
```

Then run your container with `--volume ./lssp.d:/usr/share/self-service-password/conf/conf.d`.

## Start-Up

You can run a container without linked containers:
```bash
docker run -d -p 8080:80
-e LDAP_HOST=<ldap-server-hostname>
-e LDAP_PORT=389
-e LDAP_BASE=example.com
-e LDAP_USER=<admin-username>
-e LDAP_PASS=<admin-password>
-e SMTP_HOST=<mailserver-hostname>
[-e SMTP_PORT=25]
[-e SMTP_USER=<smtp-username>]
[-e SMTP_PASS=<smtp-password>]
[-e SMTP_TLS=on]
[[-h <hostname>] | [-e SERVER_HOSTNAME=<hostname>]]
dtwardow/ldap-self-service-password:<tag>
```

Or with linked LDAP and Mail-Containers
```bash
docker run -d -p 8080:80
--link <ldap-server-container>:ldap
--link <mail-server-container>:mail
[-e SMTP_USER=<smtp-username>]
[-e SMTP_PASS=<smtp-password>]
[-e SMTP_TLS=on]
[[-h <hostname>] | [-e SERVER_HOSTNAME=<hostname>]]
dtwardow/ldap-self-service-password:<tag>
```

The examples above expose service on port `8080`, so you can point your browser to http://hostname:8765/ in order to change or reset LDAP passwords.

## Troubleshooting

**TBD**

