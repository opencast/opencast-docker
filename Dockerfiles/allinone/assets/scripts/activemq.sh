#!/bin/bash
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
