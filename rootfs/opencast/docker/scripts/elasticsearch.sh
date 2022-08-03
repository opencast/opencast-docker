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

export ELASTICSEARCH_SERVER_SCHEME="${ELASTICSEARCH_SERVER_SCHEME:-http}"
export ELASTICSEARCH_SERVER_PORT="${ELASTICSEARCH_SERVER_PORT:-9200}"
export NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_ELASTICSEARCH="${NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_ELASTICSEARCH:-25}"

opencast_elasticsearch_check() {
  echo "Run opencast_elasticsearch_check"

  opencast_helper_checkforvariables \
    "ELASTICSEARCH_SERVER_HOST" \
    "ELASTICSEARCH_SERVER_SCHEME" \
    "ELASTICSEARCH_SERVER_PORT"
}

opencast_elasticsearch_configure() {
  echo "Run opencast_elasticsearch_configure"

  opencast_helper_replaceinfile "${OPENCAST_HOME}/etc/custom.properties" \
    "ELASTICSEARCH_SERVER_HOST" \
    "ELASTICSEARCH_SERVER_SCHEME" \
    "ELASTICSEARCH_SERVER_PORT" \
    "ELASTICSEARCH_USERNAME" \
    "ELASTICSEARCH_PASSWORD"

  # shellcheck disable=SC2153
  [ -n "$ELASTICSEARCH_SERVER_HOST" ] ||
    opencast_helper_deleteinfile "${OPENCAST_HOME}/etc/custom.properties" "ELASTICSEARCH_SERVER_HOST"

  [ -n "$ELASTICSEARCH_USERNAME" ] ||
    opencast_helper_deleteinfile "${OPENCAST_HOME}/etc/custom.properties" "ELASTICSEARCH_USERNAME"

  [ -n "$ELASTICSEARCH_PASSWORD" ] ||
    opencast_helper_deleteinfile "${OPENCAST_HOME}/etc/custom.properties" "ELASTICSEARCH_PASSWORD"
}

opencast_elasticsearch_trytoconnect() {
  echo "Run opencast_elasticsearch_trytoconnect"

  if [ "$NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_ELASTICSEARCH" -eq 0 ]; then
    echo "Skip Elasticsearch connection check"
    return
  fi

  server_host=$( grep "^org.opencastproject.elasticsearch.server.hostname" "${OPENCAST_HOME}/etc/custom.properties" | tr -d ' ' | cut -d '=' -f 2- )
  server_port=$( grep "^org.opencastproject.elasticsearch.server.port"     "${OPENCAST_HOME}/etc/custom.properties" | tr -d ' ' | cut -d '=' -f 2- )

  i=1
  while [ "$i" -le "$NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_ELASTICSEARCH" ]; do
    printf "Try to connect to Elasticsearch (%s/%s) " "$i" "$NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_ELASTICSEARCH"

    # We only check if a TCP connection can be established since we don't know what permissions the configured
    # Elasticsearch user has and thus what requests are allowed.

    if nc -z -w 2 "$server_host" "$server_port"; then
      echo "SUCCEEDED"
      return
    else
      echo "FAILED"
      sleep 5
    fi
    i="$(( i + 1 ))"
  done

  echo "Could not connect to Elasticsearch"
  return 1
}
