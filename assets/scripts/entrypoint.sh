#!/bin/bash
# inspired by https://github.com/sameersbn/docker-gitlab
set -e

. ${SCRIPT_DIR}/functions

[[ $DEBUG == true ]] && set -x

appInit () {
  # configure database and check connection
  finalize_parameters

  # configure postfix, dovecot and rsyslog
  configure_lssp
}

appStart () {
  echo "Starting Apache Web-Server ..."
  exec apache2-foreground
}

appHelp () {
  echo "Available options:"
  echo " app:start          - Starts Web-Server"
  echo " app:check          - Init and Check config"
  echo " [command]          - Execute the specified linux command eg. bash."
}

case ${1} in
  app:start|app:check|app:pwGen)

    case ${1} in
      app:start)
        appInit
        appStart
      ;;
      app:check)
        appInit
      ;;
    esac

    ;;
  app:help)
    appHelp
  ;;
  *)
    exec "$@"
  ;;
esac

