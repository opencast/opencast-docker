#!/bin/bash
set -e

# Check for ActiveMQ container
if test -z "${ACTIVEMQ_PORT_61616_TCP}" -a -z "${ACTIVEMQ_BROKER_URL}"; then
  echo >&2 "error: missing ActiveMQ ${e} container"
  echo >&2 "  Did you forget to --link some_activemq_container:activemq or -e ACTIVEMQ_BROKER_URL=failover://tcp://example.opencast.org:61616 ?"
  exit 1
elif test -n "${ACTIVEMQ_PORT_61616_TCP}" -a -z "${ACTIVEMQ_BROKER_URL}"; then
  ACTIVEMQ_BROKER_URL="failover://${ACTIVEMQ_PORT_61616_TCP}"
fi

# Check for ActiveMQ settings
for e in "ACTIVEMQ_BROKER_URL" \
         "ACTIVEMQ_BROKER_USERNAME" \
         "ACTIVEMQ_BROKER_PASSWORD"; do
  if test -z "${e}"; then
    echo >&2 "error: missing ActiveMQ ${e} environment variables"
    echo >&2 "  Did you forget to -e ${e}=value ?"
    exit 1
  fi
done

# Check for required Opencast settings
for e in "ORG_OPENCASTPROJECT_SERVER_URL" \
         "ORG_OPENCASTPROJECT_SECURITY_ADMIN_USER" \
         "ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS" \
         "ORG_OPENCASTPROJECT_SECURITY_DIGEST_USER" \
         "ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS" \
; do
  if test -z "${e}"; then
    echo >&2 "error: missing Opencast ${e} environment variables"
    echo >&2 "  Did you forget to -e ${e}=value ?"
    exit 1
  fi
done

# TODO: check for DB(Type)
# TODO: set settings

exec "$@"
