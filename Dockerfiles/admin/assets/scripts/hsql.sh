#!/bin/bash
set -e

Opencast::HSQL::Check() {
  echo "Run Opencast::HSQL::Check"
  ORG_OPENCASTPROJECT_DB_DDL_GENERATION="true"
}

Opencast::HSQL::Configure() {
  Opencast::Helper::DeleteInfile "etc/custom.properties" \
    "ORG_OPENCASTPROJECT_DB_VENDOR" \
    "ORG_OPENCASTPROJECT_DB_JDBC_DRIVER" \
    "ORG_OPENCASTPROJECT_DB_JDBC_URL" \
    "ORG_OPENCASTPROJECT_DB_JDBC_USER" \
    "ORG_OPENCASTPROJECT_DB_JDBC_PASS"

  Opencast::Helper::ReplaceInfile "etc/custom.properties" \
    "ORG_OPENCASTPROJECT_DB_DDL_GENERATION"
}

Opencast::HSQL::PrintDDL() {
  echo "-- Database for HSQL is created automatically"
}
