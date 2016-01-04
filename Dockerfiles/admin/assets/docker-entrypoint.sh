#!/bin/bash
set -e

source "${OPENCAST_SCRIPTS}/helper.sh"
source "${OPENCAST_SCRIPTS}/opencast.sh"
source "${OPENCAST_SCRIPTS}/activemq.sh"
source "${OPENCAST_SCRIPTS}/db.sh"
source "${OPENCAST_SCRIPTS}/hsql.sh"
source "${OPENCAST_SCRIPTS}/jdbc.sh"
source "${OPENCAST_SCRIPTS}/mysql.sh"

Opencast::Main::Check() {
  Opencast::Opencast::Check
  Opencast::ActiveMQ::Check
  Opencast::DB::Check
}

Opencast::Main::Configure() {
  Opencast::Opencast::Configure
  Opencast::ActiveMQ::Configure
  Opencast::DB::Configure
}

# Test connection
# Create DB

case ${1} in
  app:init)
    Opencast::Main::Check
    Opencast::Main::Configure
    ;;
  app:start)
    Opencast::Main::Check
    Opencast::Main::Configure
    exec "bin/start-opencast" "server"
    ;;
  app:print:activemq.xml)
    Opencast::ActiveMQ::PrintActivemq.xml
    ;;
  app:print:dll)
    Opencast::DB::PrintDDL
    ;;
  app:help)
    echo "Usage:"
    echo "  app:help                Prints the usage information"
    echo "  app:print:dll           Prints SQL commands to set up the database"
    echo "  app:print:activemq.xml  Prints the configuration for ActiveMQ"
    echo "  app:init                Checks and configures Opencast but does not run it"
    echo "  app:start               Starts Opencast"
    echo "  [cmd] [args...]         Runs [cmd] with given arguments"
    ;;
  *)
    exec "$@"
    ;;
esac
