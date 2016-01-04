#!/bin/bash
set -e

Opencast::MySQL::Check() {
  echo "Run Opencast::MySQL::Check"
  ORG_OPENCASTPROJECT_DB_JDBC_DRIVER="com.mysql.jdbc.Driver"
}

Opencast::MySQL::Configure() {
  echo "Run Opencast::MySQL::Configure"
}

Opencast::MySQL::PrintDDL() {
  cat /opencast/docs/scripts/ddl/mysql5.sql
}
