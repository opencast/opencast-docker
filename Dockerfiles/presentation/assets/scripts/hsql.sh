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

Opencast::HSQL::Check() {
  echo "Run Opencast::HSQL::Check"

  ORG_OPENCASTPROJECT_DB_DDL_GENERATION="true"
}

Opencast::HSQL::Configure() {
  echo "Run Opencast::HSQL::Configure"

  Opencast::Helper::DeleteInfile "etc/custom.properties" \
    "ORG_OPENCASTPROJECT_DB_VENDOR" \
    "ORG_OPENCASTPROJECT_DB_JDBC_DRIVER" \
    "ORG_OPENCASTPROJECT_DB_JDBC_URL" \
    "ORG_OPENCASTPROJECT_DB_JDBC_USER" \
    "ORG_OPENCASTPROJECT_DB_JDBC_PASS"

  Opencast::Helper::ReplaceInfile "etc/custom.properties" \
    "ORG_OPENCASTPROJECT_DB_DDL_GENERATION"
}

Opencast::HSQL::TryToConnect() {
  echo "Run Opencast::HSQL::TryToConnect"
}

Opencast::HSQL::PrintDDL() {
  echo "-- Database for HSQL is created automatically"
}
