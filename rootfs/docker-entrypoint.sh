#!/bin/sh
#
# Copyright 2016 The University of Münster eLectures Team All rights reserved.
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

# shellcheck source=./opencast/docker/scripts/helper.sh
. "${OPENCAST_SCRIPTS}/helper.sh"
# shellcheck source=./opencast/docker/scripts/tz.sh
. "${OPENCAST_SCRIPTS}/tz.sh"
# shellcheck source=./opencast/docker/scripts/opencast.sh
. "${OPENCAST_SCRIPTS}/opencast.sh"
# shellcheck source=./opencast/docker/scripts/elasticsearch.sh
. "${OPENCAST_SCRIPTS}/elasticsearch.sh"
# shellcheck source=./opencast/docker/scripts/db.sh
. "${OPENCAST_SCRIPTS}/db.sh"
# shellcheck source=./opencast/docker/scripts/h2.sh
. "${OPENCAST_SCRIPTS}/h2.sh"
# shellcheck source=./opencast/docker/scripts/jdbc.sh
. "${OPENCAST_SCRIPTS}/jdbc.sh"
# shellcheck source=./opencast/docker/scripts/mariadb.sh
. "${OPENCAST_SCRIPTS}/mariadb.sh"
# shellcheck source=./opencast/docker/scripts/postgresql.sh
. "${OPENCAST_SCRIPTS}/postgresql.sh"
# shellcheck source=./opencast/docker/scripts/whisper.sh
. "${OPENCAST_SCRIPTS}/whisper.sh"


opencast_main_check() {
  echo "Run opencast_main_check"

  opencast_opencast_check
  if opencast_helper_dist_allinone || opencast_helper_dist_develop || opencast_helper_dist_admin; then
    opencast_elasticsearch_check
  fi
  opencast_db_check
}

opencast_main_configure() {
  echo "Run opencast_main_configure"

  opencast_opencast_configure
  opencast_elasticsearch_configure
  opencast_db_configure
}

opencast_file_env() {
  file_env ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS
  file_env ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS
  file_env ORG_OPENCASTPROJECT_DB_JDBC_PASS
}

opencast_main_update_ca() {
  echo "Run opencast_main_update_ca"

  update-ca-certificates
  trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$JAVA_HOME/lib/security/cacerts"
}

opencast_main_init() {
  echo "Run opencast_main_init"

  opencast_file_env
  opencast_tz_set
  opencast_main_update_ca
  opencast_whisper_init

  if opencast_helper_customconfig; then
    echo "Found custom config in ${OPENCAST_CUSTOM_CONFIG}"
    opencast_main_sync_config
  else
    echo "No custom config found"
    opencast_main_check
    opencast_main_configure
  fi
}

opencast_main_sync_config() {
  echo "Run opencast_main_sync_config"

  # Create new staged output directory
  rm -rf "${OPENCAST_STAGE_OUT_HOME}"
  mkdir -p "${OPENCAST_STAGE_OUT_HOME}"

  # Order is important:
  #  1. stage base (config)
  #  2. stage custom config
  #  3. configure staged config
  #  4. deploy staged config
  opencast_helper_stage_base
  opencast_helper_stage_customconfig
  OPENCAST_HOME="${OPENCAST_STAGE_OUT_HOME}" opencast_main_configure
  opencast_helper_deploy_staged_config
}

opencast_main_watch_customconfig_job() {
  while true; do
    if opencast_helper_customconfig; then
      opencast_helper_customconfig_wait_for_change
      opencast_main_sync_config
    else
      sleep 60
    fi
  done
}

opencast_main_start() {
  echo "Run opencast_main_start"

  # In some corner cases, when the container is restarted, the pid file of the
  # previous Opencast process is still present preventing a normal start. This
  # function will only be called once per container start when no other
  # processes are running. We therefore can just clean up the old pid file.
  rm -rf /opencast/data/pid /opencast/instances/instance.properties

  opencast_main_watch_customconfig_job &
  export OC_WATCH_CUSTOM_CONFIG_PID=$!

  if opencast_helper_dist_develop; then
    exec gosu "${OPENCAST_USER}":"${OPENCAST_GROUP}" bin/start-opencast debug
  fi

  gosu "${OPENCAST_USER}":"${OPENCAST_GROUP}" bin/start-opencast daemon &
  OC_PID=$!
  trap opencast_main_stop TERM INT

  status=0

  set +e
  while kill -0 "$OC_PID" >/dev/null 2>&1; do
    wait "$OC_PID"
    status=$?
  done
  set -e

  return $status
}

opencast_main_stop() {
  echo "Run opencast_main_stop"

  bin/stop-opencast &
  kill "$OC_WATCH_CUSTOM_CONFIG_PID"
}

case ${1} in
  app:init)
    opencast_main_init
    ;;
  app:start)
    opencast_main_init
    opencast_db_trytoconnect
    if opencast_helper_dist_allinone || opencast_helper_dist_develop || opencast_helper_dist_admin; then
      opencast_elasticsearch_trytoconnect
    fi
    opencast_main_start
    ;;
  app:help)
    echo "Usage:"
    echo "  app:help         Prints the usage information"
    echo "  app:init         Checks and configures Opencast but does not run it"
    echo "  app:start        Starts Opencast"
    echo "  [cmd] [args...]  Runs [cmd] with given arguments"
    ;;
  *)
    exec "$@"
    ;;
esac
