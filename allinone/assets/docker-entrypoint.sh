#!/bin/bash
set -e

source "${OPENCAST_SCRIPTS}/helper.sh"
source "${OPENCAST_SCRIPTS}/opencast.sh"
source "${OPENCAST_SCRIPTS}/activemq.sh"
source "${OPENCAST_SCRIPTS}/db.sh"
source "${OPENCAST_SCRIPTS}/hsql.sh"
source "${OPENCAST_SCRIPTS}/jdbc.sh"

Opencast::Main::CheckAndSetDefault() {
  Opencast::Opencast::CheckAndSetDefault
  Opencast::ActiveMQ::CheckAndSetDefault
  Opencast::DB::CheckAndSetDefault
}

Opencast::Main::Configure() {
  Opencast::Opencast::Configure
  Opencast::ActiveMQ::Configure
  Opencast::DB::Configure
}

# Test connection
# Create DB

case ${1} in
  *)
    Opencast::Main::CheckAndSetDefault
    Opencast::Main::Configure
    exec "$@"
    ;;
esac
