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

export OPENSEARCH_SERVER_SCHEME="${OPENSEARCH_SERVER_SCHEME:-http}"
export OPENSEARCH_SERVER_PORT="${OPENSEARCH_SERVER_PORT:-9200}"
export NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_OPENSEARCH="${NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_OPENSEARCH:-25}"

opencast_opensearch_check() {
  echo "Run opencast_opensearch_check"

  opencast_helper_checkforvariables \
    "OPENSEARCH_SERVER_HOST" \
    "OPENSEARCH_SERVER_SCHEME" \
    "OPENSEARCH_SERVER_PORT"
}

opencast_opensearch_configure() {
  echo "Run opencast_opensearch_configure"

  opencast_helper_replaceinfile "${OPENCAST_HOME}/etc/custom.properties" \
    "OPENSEARCH_SERVER_HOST" \
    "OPENSEARCH_SERVER_SCHEME" \
    "OPENSEARCH_SERVER_PORT" \
    "OPENSEARCH_USERNAME" \
    "OPENSEARCH_PASSWORD"

  [ -n "$OPENSEARCH_SERVER_HOST" ] ||
    opencast_helper_deleteinfile "${OPENCAST_HOME}/etc/custom.properties" "OPENSEARCH_SERVER_HOST"

  [ -n "$OPENSEARCH_USERNAME" ] ||
    opencast_helper_deleteinfile "${OPENCAST_HOME}/etc/custom.properties" "OPENSEARCH_USERNAME"

  [ -n "$OPENSEARCH_PASSWORD" ] ||
    opencast_helper_deleteinfile "${OPENCAST_HOME}/etc/custom.properties" "OPENSEARCH_PASSWORD"
}

opencast_opensearch_trytoconnect() {
  echo "Run opencast_opensearch_trytoconnect"

  if [ "$NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_OPENSEARCH" -eq 0 ]; then
    echo "Skip OpenSearch connection check"
    return
  fi

  server_host=$( grep "^org.opencastproject.opensearch.server.hostname" "${OPENCAST_HOME}/etc/custom.properties" | tr -d ' ' | cut -d '=' -f 2- )
  server_port=$( grep "^org.opencastproject.opensearch.server.port"     "${OPENCAST_HOME}/etc/custom.properties" | tr -d ' ' | cut -d '=' -f 2- )

  i=1
  while [ "$i" -le "$NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_OPENSEARCH" ]; do
    printf "Try to connect to OpenSearch (%s/%s) " "$i" "$NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_OPENSEARCH"

    # We only check if a TCP connection can be established since we don't know what permissions the configured
    # OpenSearch user has and thus what requests are allowed.

    if nc -z -w 2 "$server_host" "$server_port"; then
      echo "SUCCEEDED"
      return
    else
      echo "FAILED"
      sleep 5
    fi
    i="$(( i + 1 ))"
  done

  echo "Could not connect to OpenSearch"
  return 1
}
