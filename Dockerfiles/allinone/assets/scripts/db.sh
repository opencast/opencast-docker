#!/bin/bash
set -e

ORG_OPENCASTPROJECT_DB_VENDOR="${ORG_OPENCASTPROJECT_DB_VENDOR:-HSQL}"

Opencast::DB::Check() {
  echo "Run Opencast::DB::Check"

  case "$ORG_OPENCASTPROJECT_DB_VENDOR" in
    HSQL)
      Opencast::HSQL::Check
      ;;
    MySQL)
      Opencast::MySQL::Check
      Opencast::JDBC::Check
      ;;
    *)
      echo >&2 "error: ${ORG_OPENCASTPROJECT_DB_VENDOR} is currently not supported as database vendor"
      exit 1
      ;;
  esac
}

Opencast::DB::Configure() {
  echo "Run Opencast::DB::Configure"

  case "$ORG_OPENCASTPROJECT_DB_VENDOR" in
    HSQL)
      Opencast::HSQL::Configure
      ;;
    MySQL)
      Opencast::MySQL::Configure
      Opencast::JDBC::Configure
      ;;
    *)
      echo >&2 "error: ${ORG_OPENCASTPROJECT_DB_VENDOR} is currently not supported as database vendor"
      exit 1
      ;;
  esac
}

Opencast::DB::PrintDDL() {
  case "$ORG_OPENCASTPROJECT_DB_VENDOR" in
    HSQL)
      Opencast::HSQL::PrintDDL
      ;;
    MySQL)
      Opencast::MySQL::PrintDDL
      ;;
    *)
      echo >&2 "error: ${ORG_OPENCASTPROJECT_DB_VENDOR} is currently not supported as database vendor"
      exit 1
      ;;
  esac
}
