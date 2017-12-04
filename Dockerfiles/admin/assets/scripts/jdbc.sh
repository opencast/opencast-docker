#!/bin/sh
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

opencast_jdbc_check() {
  echo "Run opencast_jdbc_check"

  opencast_helper_checkforvariables \
    "ORG_OPENCASTPROJECT_DB_DDL_GENERATION" \
    "ORG_OPENCASTPROJECT_DB_JDBC_DRIVER" \
    "ORG_OPENCASTPROJECT_DB_JDBC_URL" \
    "ORG_OPENCASTPROJECT_DB_JDBC_USER" \
    "ORG_OPENCASTPROJECT_DB_JDBC_PASS"
}

opencast_jdbc_configure() {
  echo "Run opencast_jdbc_configure"

  export ORG_OPENCASTPROJECT_DB_DDL_GENERATION="${ORG_OPENCASTPROJECT_DB_DDL_GENERATION:-false}"

  opencast_helper_replaceinfile "etc/custom.properties" \
    "ORG_OPENCASTPROJECT_DB_VENDOR" \
    "ORG_OPENCASTPROJECT_DB_DDL_GENERATION" \
    "ORG_OPENCASTPROJECT_DB_JDBC_DRIVER" \
    "ORG_OPENCASTPROJECT_DB_JDBC_URL" \
    "ORG_OPENCASTPROJECT_DB_JDBC_USER" \
    "ORG_OPENCASTPROJECT_DB_JDBC_PASS"
}

opencast_jdbc_trytoconnect() {
  echo "Run opencast_jdbc_trytoconnect"

  driver=$(awk -F "=" '/org\.opencastproject\.db\.jdbc\.driver/ {print $2}' etc/custom.properties | tr -d ' ')
  url=$(awk -F "=" '/org\.opencastproject\.db\.jdbc\.url/ {print $2}' etc/custom.properties | tr -d ' ')
  user=$(awk -F "=" '/org\.opencastproject\.db\.jdbc\.user/ {print $2}' etc/custom.properties | tr -d ' ')
  password=$(awk -F "=" '/org\.opencastproject\.db\.jdbc\.pass/ {print $2}' etc/custom.properties | tr -d ' ')
  db_jar=$(find "${OPENCAST_HOME}/system/org/opencastproject" -name 'matterhorn-db-*.jar')

  java -cp "${OPENCAST_SCRIPTS}:${db_jar}" \
    TryToConnectToDb \
    "${driver}" \
    "${url}" \
    "${user}" \
    "${password}" \
    "${NUMER_OF_TIMES_TRYING_TO_CONNECT_TO_DB}"
}
