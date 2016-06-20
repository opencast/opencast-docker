#!/bin/sh
#
# Copyright 2016 The WWU eLectures Team All rights reserved.
#
# Licensed under the Educational Community License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
#     http://opensource.org/licenses/ECL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# shellcheck source=./scripts/helper.sh
. "${OPENCAST_SCRIPTS}/helper.sh"
# shellcheck source=./scripts/opencast.sh
. "${OPENCAST_SCRIPTS}/opencast.sh"
# shellcheck source=./scripts/activemq.sh
. "${OPENCAST_SCRIPTS}/activemq.sh"
# shellcheck source=./scripts/db.sh
. "${OPENCAST_SCRIPTS}/db.sh"
# shellcheck source=./scripts/hsql.sh
. "${OPENCAST_SCRIPTS}/hsql.sh"
# shellcheck source=./scripts/jdbc.sh
. "${OPENCAST_SCRIPTS}/jdbc.sh"
# shellcheck source=./scripts/mysql.sh
. "${OPENCAST_SCRIPTS}/mysql.sh"


opencast_main_check() {
  echo "Run opencast_main_check"

  opencast_opencast_check
  opencast_activemq_check
  opencast_db_check
}

opencast_main_configure() {
  echo "Run opencast_main_configure"

  opencast_opencast_configure
  opencast_activemq_configure
  opencast_db_configure
}

opencast_main_init() {
  echo "Run opencast_main_init"

  if opencast_helper_customconfig; then
    echo "Found custom config in ${OPENCAST_CUSTOM_CONFIG}"
    echo "Run opencast_helper_copycustomconfig"
    opencast_helper_copycustomconfig
  else
    echo "No custom config found"
    opencast_main_check
    opencast_main_configure
  fi
}

opencast_main_start() {
  echo "Run opencast_main_start"
  su-exec "${OPENCAST_USER}":"${OPENCAST_GROUP}" bin/start-opencast server
}

case ${1} in
  app:init)
    opencast_main_init
    ;;
  app:start)
    opencast_main_init
    opencast_db_trytoconnect
    opencast_main_start
    ;;
  app:print:activemq.xml)
    opencast_activemq_printactivemqxml
    ;;
  app:print:dll)
    opencast_db_printddl
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
