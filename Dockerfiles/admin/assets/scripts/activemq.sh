#!/bin/bash
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

Opencast::ActiveMQ::Check() {
  echo "Run Opencast::ActiveMQ::Check"

  # Check for ActiveMQ container
  #
  # $ACTIVEMQ_BROKER_URL is prefered over $ACTIVEMQ_PORT_61616_TCP and holds
  # the final connection string.
  if test -z "${ACTIVEMQ_PORT_61616_TCP}" -a -z "${ACTIVEMQ_BROKER_URL}"; then
    echo >&2 "error: missing ActiveMQ ${e} container"
    echo >&2 "  Did you forget to --link some_activemq_container:activemq or -e ACTIVEMQ_BROKER_URL=failover://tcp://example.opencast.org:61616 ?"
    exit 1
  elif test -n "${ACTIVEMQ_PORT_61616_TCP}" -a -z "${ACTIVEMQ_BROKER_URL}"; then
    ACTIVEMQ_BROKER_URL="failover://${ACTIVEMQ_PORT_61616_TCP}"
  fi

  Opencast::Helper::CheckForVariables \
    "ACTIVEMQ_BROKER_URL" \
    "ACTIVEMQ_BROKER_USERNAME" \
    "ACTIVEMQ_BROKER_PASSWORD"
}

Opencast::ActiveMQ::Configure() {
  echo "Run Opencast::ActiveMQ::Configure"

  Opencast::Helper::ReplaceInfile "etc/custom.properties" \
    "ACTIVEMQ_BROKER_URL" \
    "ACTIVEMQ_BROKER_USERNAME" \
    "ACTIVEMQ_BROKER_PASSWORD"
}

Opencast::ActiveMQ::PrintActivemq.xml() {
  # TODO: read env variables and add config for jaasAuthenticationPlugin
  cat /opencast/docs/scripts/activemq/activemq.xml
}
