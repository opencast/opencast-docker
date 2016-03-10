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

ORG_OPENCASTPROJECT_DB_VENDOR="${ORG_OPENCASTPROJECT_DB_VENDOR:-HSQL}"
NUMER_OF_TIMES_TRYING_TO_CONNECT_TO_DB="${NUMER_OF_TIMES_TRYING_TO_CONNECT_TO_DB:-25}"

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

Opencast::DB::TryToConnect() {
  echo "Run Opencast::DB::TryToConnect"

  case "$ORG_OPENCASTPROJECT_DB_VENDOR" in
    HSQL)
      Opencast::HSQL::TryToConnect
      ;;
    MySQL)
      Opencast::JDBC::TryToConnect
      ;;
    *)
      echo >&2 "error: ${ORG_OPENCASTPROJECT_DB_VENDOR} is currently not supported as database vendor"
      exit 1
      ;;
  esac
}

Opencast::DB::PrintDDL() {
  echo "-- Created with Opencast version ${OPENCAST_VERSION}"
  echo
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
