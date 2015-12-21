#!/bin/bash
set -e

Opencast::DB::CheckAndSetDefault() {
  ORG_OPENCASTPROJECT_DB_VENDOR="${ORG_OPENCASTPROJECT_DB_VENDOR:-HSQL}"
  ORG_OPENCASTPROJECT_DB_DDL_GENERATION="${ORG_OPENCASTPROJECT_DB_DDL_GENERATION:-false}"

  case "$ORG_OPENCASTPROJECT_DB_VENDOR" in
    HSQL)
      Opencast::HSQL::CheckAndSetDefault
      ;;
    MySQL)
      Opencast::JDBC::CheckAndSetDefault
      ;;
    *)
      echo >&2 "error: ${ORG_OPENCASTPROJECT_DB_VENDOR} is currently not supported as DB vendor"
      exit 1
      ;;
  esac
}

Opencast::DB::Configure() {
  case "$ORG_OPENCASTPROJECT_DB_VENDOR" in
    HSQL)
      Opencast::HSQL::Configure
      ;;
    MySQL)
      Opencast::JDBC::Configure
      ;;
    *)
      echo >&2 "error: ${ORG_OPENCASTPROJECT_DB_VENDOR} is currently not supported as DB vendor"
      exit 1
      ;;
  esac
}
